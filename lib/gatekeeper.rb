#!/usr/bin/env ruby

# ==Usage
#   Load and maintain all users for the 'envy-labs' project:
#     PROJECT=envy-labs ruby gatekeeper.rb
#   Normally, this would be done from a cron task:
#     */5 * * * * PROJECT=envy-labs ruby gatekeeper.rb
#

require 'openssl'
require 'base64'
require 'net/http'
require 'uri'
require 'yaml'
require 'cgi'

module ExecutionResult
  
  def success?
    @success || false
  end
  
  def success=(value)
    @success = value
  end
  
end

HTTP_ERRORS = [ Timeout::Error,
                Errno::EINVAL,
                Errno::ECONNRESET,
                EOFError,
                Net::HTTPBadResponse,
                Net::HTTPHeaderSyntaxError,
                Net::ProtocolError          ]     unless defined?(HTTP_ERRORS)

##
# Execute a file on the server with optional parameters.
# 
def execute(executable, options = {})
  executable_path = `/usr/bin/env which "#{executable}"`.strip
  if $?.success?
    result = `\"#{executable_path}\" #{options[:parameters]}`.strip
    result.extend(ExecutionResult)
    result.success = $?.success?
    log(%|Execution of "#{executable_path}" #{options[:parameters]} failed|, :fail => true) if !result.success? && options[:fail]
    result
  else
    log(%|Could not locate "#{executable}" in the user's environment|, :fail => true)
  end
end

##
# Log a message to syslog.
# 
def log(message, options = {})
  execute("logger", :parameters => %|-i -t "Gatekeeper" "#{message}"|)
  exit(1) if options[:fail]
end

##
# Envy Labs ShellUsers
#
class ShellUser
  
  Version = '%CURRENT_KEYMASTER_VERSION%'
  
  PublicKey = <<-KEY
-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEA3qENRm18NmxUPQ8KFUbZdRyc7aQgSfnzgn3a5a1VYVOBo+KuuOyN
o7U/j9ICy7NFqsNTF91/BDJKiApQOd63l9aS7xp7KzpOferjnFqrDCcOfxgNpy3T
vIoJEwxDepvMnkgyKcdzrFmtwYoFwEEtLhA8JDvuTrFukjFK79ON4/PmBRPuOsnW
7+kZ205AAGmfguxr7yO1pCFwSvYaMqoR8QSmfVjGUKBlgGDaD0iWrbuc5Zqajg9v
qPvCNQw4+/t2QAvr1IWUKgXkO4e5Rw4o2bglTW23akyXCCW+f0LMMXOHzaiDBtzd
oqzuY9HMI8ue9NmGPxahF3pHxnnBhBZojwIDAQAB
-----END RSA PUBLIC KEY-----
KEY
  
  def self.manage(project)
    yaml = data_for(project)
    user_attributes = YAML.load(yaml).freeze
    add_users(user_attributes)
    remove_unlisted_users(user_attributes)
  rescue *HTTP_ERRORS
    log("HTTP Exception - #{$!.class.name} - #{$!.message}", :fail => true)
  end
  
  def self.add_users(attributes)
    attributes.map { |a| ShellUser.new(a).setup! }
  end 
  
  def self.remove_unlisted_users(attributes)
    local_logins = execute("cat", :parameters => %|/etc/group \| grep "^envylabs_accounts"|, :fail => true).split(':').last
    return unless local_logins
    
    local_logins = local_logins.strip.split(',')
    logins_to_delete = local_logins - attributes.collect { |a| a['login'] }
    logins_to_delete.map { |login| ShellUser.new('login' => login).destroy! }
  end
  
  def self.data_for(project)
    uri = URI.parse("http://keymaster.envylabs.com/projects/#{project}/users.yaml")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.path)
    end
    
    exit(1) unless response_valid?(response)
    
    unless current_version?(response['Api-Version'])
      log("Local version out-of-date, downloading and aborting.")
      download_new_version!
      exit(0)
    end
    
    response.body
  end
  
  def self.response_valid?(net_http_response)
    unless net_http_response.kind_of?(Net::HTTPSuccess)
      log("Non-200 Server Response - Code #{net_http_response.code}. Aborting.")
      return false
    end
    
    unless OpenSSL::PKey::RSA.new(PublicKey).
      verify(OpenSSL::Digest::SHA256.new, Base64.decode64(CGI.unescape(net_http_response['Response-Signature'])), net_http_response.body)
      log("Invalid signature received. Aborting.")
      return false
    end
    
    true
  end

  attr_accessor :login, :full_name, :public_key, :uid

  def initialize(attributes = {})
    self.login      = attributes['login']
    self.full_name  = attributes['full_name']
    self.public_key = attributes['public_ssh_key']
    self.uid        = attributes['uid']
  end

  def setup!
    create! unless exists?
    add_authorized_key! unless has_authorized_key?
  end

  def exists?
    execute("egrep", :parameters => "-q ^#{self.login} /etc/passwd").success?
  end

  def create!
    log(%|Creating "#{self.login}" user|)
    execute("useradd", :parameters => "--groups sudo,envylabs_accounts --create-home --shell /bin/bash --uid #{self.uid} --comment \"#{self.full_name}\" --password \`dd if=/dev/urandom count=1 2> /dev/null | sha512sum | cut -c-128\` #{self.login}", :fail => true)
  end
  
  def destroy!
    log(%|Destroying "#{self.login}" user|)
    execute("killall", :parameters => %|-u "#{self.login}"|, :fail => true)
    sleep(2) # allow the user to be logged out
    execute("userdel", :parameters => %|-rf "#{self.login}"|, :fail => true)
  end

  def has_authorized_key?
    return false unless File.exist?(authorized_keys_path)
    execute("grep", :parameters => %|-q "#{self.public_key}" "#{authorized_keys_path}"|).success?
  end

  def add_authorized_key!
    execute("mkdir", :parameters => %|-p "#{home_path}/.ssh"|, :fail => true)
    execute("touch", :parameters => %|"#{authorized_keys_path}"|, :fail => true)
    chown_home
    execute("echo", :parameters => %|#{self.public_key} > "#{authorized_keys_path}" && chmod 0600 "#{authorized_keys_path}"|, :fail => true)
  end

  def chown_home
    execute("chown", :parameters => %|-R #{login}:#{login} "#{home_path}"|, :fail => true)
  end

  def home_path
    "/home/#{login}"
  end

  def authorized_keys_path
    "#{home_path}/.ssh/authorized_keys"
  end
  
  
  private
  
  
  def self.current_version?(version)
    Version == version
  end
  
  def self.download_new_version!
    uri = URI.parse("http://keymaster.envylabs.com/gatekeeper.rb")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.path)
    end
    
    exit(1) unless response_valid?(response)
    
    File.open(File.expand_path(__FILE__), 'w') { |f| f.write response.body }
    log("Gatekeeper updated.")
  end
  
end

##
# Need to run as root/sudo
#
unless execute("id", :parameters => %|-u|) == '0'
  puts "Please run as root/sudo"
  log("Please run as root/sudo", :fail => true)
end

if ENV['PROJECT'].nil? || ENV['PROJECT'] == ''
  puts "Please specify the project"
  log("Please specify the project", :fail => true)
end

##
# Check for the sudo group, add if it doesn't exist.
#
unless execute("egrep", :parameters => %|-q ^sudo /etc/group|).success?
  execute("groupadd", :parameters => "sudo", :fail => true)
end

##
# Check for correct sudoer line, add if it doesn't exist.
#
unless execute("grep", :parameters => %|-q "%sudo   ALL=NOPASSWD: ALL" /etc/sudoers|).success?
  execute("echo", :parameters => %|"%sudo   ALL=NOPASSWD: ALL" >> /etc/sudoers|, :fail => true)
end

##
# Check for the envylabs group, add if it doesn't exist.
#
unless execute("egrep", :parameters => %|-q ^envylabs_accounts /etc/group|).success?
  execute("groupadd", :parameters => %|envylabs_accounts|, :fail => true)
end

ShellUser.manage(ENV['PROJECT'].to_s.strip.downcase)
