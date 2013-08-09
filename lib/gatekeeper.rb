#!/usr/bin/env ruby

# ==Usage
#   Load and maintain all users for the 'envy-labs' project:
#     PROJECT=envy-labs ruby gatekeeper.rb
#   Normally, this would be done from a cron task:
#     */5 * * * * PROJECT=envy-labs /root/gatekeeper.rb &>/dev/null
#

ENV['PATH'] = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

require 'openssl'
require 'base64'
require 'net/http'
require 'uri'
require 'yaml'
require 'cgi'

HTTP_ERRORS = [ Timeout::Error,
                Errno::EINVAL,
                Errno::ECONNRESET,
                EOFError,
                Net::HTTPBadResponse,
                Net::HTTPHeaderSyntaxError,
                Net::ProtocolError          ]     unless defined?(HTTP_ERRORS)

module Keymaster

  def self.host
    @_host ||= '%CURRENT_KEYMASTER_HOST%'
  end

  ##
  # Returns the version of the Keymaster in which this Gatekeeper instance
  # is compatible against.
  #
  def self.version
    @_version ||= '%CURRENT_KEYMASTER_VERSION%'
  end

  ##
  # Returns a collection of Users allowed to access the requested project.
  #
  def self.users_for_project(project)
    yaml  = query("http://#{self.host}/projects/#{project}/users.yaml")
    YAML.load(yaml).collect { |user_data| ShellUser.new(user_data) }
  end

  ##
  # Returns +true+ if the given content (with it's associated signature) came
  # from the Keymaster.  This method performs an RSA signature verification
  # against the pre-shared public key.
  #
  def self.valid?(content, signature)
    rsa.verify(digest, signature, content)
  end


  private


  def self.rsa
    @_rsa ||= OpenSSL::PKey::RSA.new(public_key)
  rescue OpenSSL::PKey::RSAError
    log("Invalid pre-shared RSA public key.  Aborting.")
    exit(1)
  end

  def self.digest
    @_rsa_digest ||= OpenSSL::Digest::SHA256.new
  end

  ##
  # Returns the RSA Public Key for the Keymaster.  All data collected from
  # the Keymaster should be signed with the companion RSA Private Key.
  #
  def self.public_key
    @_public_key ||= "%CURRENT_PUBLIC_KEY%"
  end

  ##
  # Returns the data (body) from GET requesting the given URL.
  #
  def self.query(url, options = {})
    uri       = URI.parse(url)
    response  = Net::HTTP.start(uri.host, uri.port) do |http|
      yield(http) if block_given?
      http.get(uri.path)
    end

    unless response.kind_of?(Net::HTTPSuccess)
      log("Non-200 Server Response - Code #{response.code}.", :fail => true)
    end

    unless valid?(response.body.strip, Base64.decode64(CGI.unescape(response['X-Response-Signature']))) || options[:ignore_signature]
      log("Invalid signature received. Aborting.", :fail => true)
    end

    unless current?(response['X-API-Version']) || options[:ignore_version]
      log("Local version out-of-date, downloading and aborting.")
      update!
      exit(0)
    end

    response.body
  rescue *HTTP_ERRORS
    log("HTTP Error occurred: #{$!.class.name} - #{$!.message}", :fail => true)
  end

  ##
  # Returns +true+ if the given version matches the locally compatible
  # Keymaster.version.
  #
  def self.current?(version)
    Keymaster.version == version
  end

  ##
  # Downloads the newest version of the Gatekeeper from the server and
  # overwrites the local installation.
  #
  def self.update!
    data = query("http://#{self.host}/gatekeeper.rb", :ignore_version => true)
    File.open(File.expand_path(__FILE__), 'w') { |f| f.write data }
    log("Gatekeeper updated.")
  end

end

module LocalMachine

  module ExecutionResult

    def success?
      @success || false
    end

    def success=(value)
      @success = value
    end

  end

  ##
  # Execute a file on the server with optional parameters.
  #
  def self.execute(executable, options = {})
    executable_path = `/usr/bin/env which "#{executable}"`.strip
    if $?.success?
      result = `\"#{executable_path}\" #{options[:parameters]}`.strip
      result.extend(ExecutionResult)
      result.success = $?.success?
      log(%|Execution of "#{executable_path}" #{options[:parameters]} failed|, :fail => options[:fail]) unless result.success? || options[:log_fail] == false
      result
    else
      log(%|Could not locate "#{executable}" in the user's environment|, :fail => true)
    end
  end

  ##
  # Log a message to syslog.
  #
  def self.log(message, options = {})
    puts message
    execute("logger", :parameters => %|-i -t "Gatekeeper" "#{message}"|)
    exit(1) if options[:fail]
  end

  def self.setup!
    add_group("sudo")
    set_sudo_nopasswd
    add_group("webapps")
    add_group("envylabs_accounts")
  end


  private


  ##
  # Check for correct sudoer line, add if it doesn't exist.
  #
  def self.set_sudo_nopasswd
    unless execute("grep", :parameters => %|-q "%sudo   ALL=NOPASSWD: ALL" /etc/sudoers|, :log_fail => false).success?
      execute("echo", :parameters => %|"%sudo   ALL=NOPASSWD: ALL" >> /etc/sudoers|, :fail => true)
    end
  end

  ##
  # Add the given group unless it's already present on the system.
  #
  def self.add_group(group)
    unless execute("egrep", :parameters => %|-q ^#{group} /etc/group|, :log_fail => false).success?
      execute("groupadd", :parameters => group, :fail => true)
    end
  end
end

##
# Envy Labs ShellUsers
#
class ShellUser

  attr_accessor :login, :full_name, :public_key, :uid


  ##
  # Synchronizes shell users on the system with those dictated by the
  # Keymaster server for the requested project.
  #
  # This also synchronizes the deploy user's authorized keys to match those
  # users who have access to the server.
  #
  def self.synchronize(project)
    users = Keymaster.users_for_project(project)
    add_users(users)
    remove_unlisted_users(users)

    new({
      :login      => 'deploy',
      :full_name  => 'Application Deployment User',
      :public_ssh_key  => users.collect { |u| u.public_key }
    }, {
      :groups     => 'webapps'
    }).setup!
  end


  def initialize(attributes = {}, options = {})
    self.login      = attributes['login']           || attributes[:login]
    self.full_name  = attributes['full_name']       || attributes[:full_name]
    self.public_key = attributes['public_ssh_key']  || attributes[:public_ssh_key]
    self.uid        = attributes['uid']             || attributes[:uid]
    @groups         = options[:groups]
  end

  def setup!
    create! unless exists?
    synchronize_authorized_keys!
  end

  def destroy!
    log(%|Destroying "#{self.login}" user|)
    execute("killall", :parameters => %|-u "#{self.login}"|)
    sleep(2) # allow the user to be logged out
    execute("userdel", :parameters => %|-rf "#{self.login}"|, :fail => true)
  end

  def synchronize_authorized_keys!
    keys = [public_key].flatten

    make_authorized_keys_file

    data = File.read(authorized_keys_path).strip
    data = data.gsub(%r{#{Regexp.escape(comment_open)}.*?#{Regexp.escape(comment_close)}}m, '').strip
    keys.each { |key| data = data.gsub(%r{#{Regexp.escape(key)}}, '') } # temporarily, explicitly remove keys left over after stripping header block.  This is because existing envylabs users will have authorized keys outside of the block (set before this was well managed).
    data << "\n#{comment_open}"
    keys.each { |key| data << "\n#{key}" }
    data << "\n#{comment_close}"
    data << "\n"
    File.open(authorized_keys_path, 'w') { |file| file.write data }
  end


  private


  def self.add_users(users)
    users.each { |user| user.setup! }
  end

  def self.remove_unlisted_users(users)
    local_logins = execute("cat", :parameters => %|/etc/group \| grep "^envylabs_accounts"|, :fail => true).split(':').last
    return unless local_logins
    local_logins = local_logins.strip.split(',')
    local_logins = local_logins - users.collect { |u| u.login }
    local_logins.each { |login| new('login' => login).destroy! }
  end


  def exists?
    execute("egrep", :parameters => "-q ^#{self.login} /etc/passwd", :log_fail => false).success?
  end

  def create!
    log(%|Creating "#{self.login}" user|)
    execute("useradd", :parameters => "--groups #{@groups || 'sudo,envylabs_accounts'} --create-home --shell /bin/bash #{uid ? "--uid #{self.uid}" : ''} --comment \"#{self.full_name}\" --password \`dd if=/dev/urandom count=1 2> /dev/null | sha512sum | cut -c-128\` #{self.login}", :fail => true)
  end

  def chown_home
    execute("chown", :parameters => %|-R #{login}:#{login} "#{home_path}"|, :fail => true)
  end

  def home_path
    "/home/#{login}"
  end

  def make_home
    return if File.exist?(home_path)
    execute("mkdir", :parameters => %|-p "#{home_path}"|, :fail => true)
    chown_home
  end

  def authorized_keys_path
    "#{home_path}/.ssh/authorized_keys"
  end

  def make_authorized_keys_file
    return if File.exist?(authorized_keys_path)
    make_home
    execute("mkdir", :parameters => %|-p "#{home_path}/.ssh"|, :fail => true)
    execute("touch", :parameters => %|"#{authorized_keys_path}"|, :fail => true)
    execute("chown", :parameters => %|-R #{login}:#{login} "#{home_path}/.ssh"|, :fail => true)
    execute("chmod", :parameters => %|700 "#{home_path}/.ssh"|, :fail => true)
    execute("chmod", :parameters => %|600 "#{authorized_keys_path}"|, :fail => true)
  end

  def comment_open
    '# Begin Gatekeeper generated keys'
  end

  def comment_close
    '# End Gatekeeper generated keys'
  end

end


def log(message, options = {})
  LocalMachine.log(message, options)
end

def execute(executable, options = {})
  LocalMachine.execute(executable, options)
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

LocalMachine.setup!
ShellUser.synchronize(ENV['PROJECT'].to_s.strip.downcase)
