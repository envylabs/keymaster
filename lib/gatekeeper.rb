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

##
# Envy Labs ShellUsers
#
class ShellUser
  
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
  end
  
  def self.add_users(attributes)
    attributes.map { |a| ShellUser.new(a).setup! }
  end 
  
  def self.remove_unlisted_users(attributes)
    local_logins = `cat /etc/group | grep "^envylabs_accounts"`.split(':').last
    return unless local_logins
    
    local_logins = local_logins.strip.split(',')
    logins_to_delete = local_logins - attributes.collect { |a| a['login'] }
    logins_to_delete.map { |login| ShellUser.new('login' => login).destroy! }
  end
  
  def self.data_for(project)
    uri = URI.parse("http://keymaster.envylabs.com/projects/#{project}/users.yaml")
    response = nil
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.get(uri.path)
    end
    
    unless response_valid?(response.body, response['Response-Signature'])
      `logger -i -t "Gatekeeper" "Invalid signature received. Aborting."`
      raise("Invalid data signature.  Aborting.")
    end
    
    response.body
  end
  
  def self.response_valid?(data, signature)
    OpenSSL::PKey::RSA.new(PublicKey).
      verify(OpenSSL::Digest::SHA256.new, Base64.decode64(CGI.unescape(signature)), data.strip)
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
    `egrep -q ^#{self.login} /etc/passwd`
    success?
  end

  def create!
    `logger -i -t "Gatekeeper" "Creating \"#{self.login}\" user"`
    `useradd --groups sudo,envylabs_accounts --create-home --shell /bin/bash --uid #{self.uid} --comment "#{self.full_name}" --password \`dd if=/dev/urandom count=1 2> /dev/null | sha512sum | cut -c-128\` #{self.login}`
    success?
  end
  
  def destroy!
    `logger -i -t "Gatekeeper" "Destroying \"#{self.login}\" user"`
    `killall -u "#{self.login}"`
    sleep(2) # allow the user to be logged out
    `userdel -rf "#{self.login}"`
    success?
  end

  def has_authorized_key?
    return false unless File.exist?(authorized_keys_path)
    `grep -q '#{self.public_key}' #{authorized_keys_path}`
    success?
  end

  def add_authorized_key!
    `mkdir -p #{home_path}/.ssh`
    `touch #{authorized_keys_path}`
    chown_home
    `echo #{self.public_key} > #{authorized_keys_path} && chmod 0600 #{authorized_keys_path}`
    success?
  end

  def chown_home
    `chown -R #{login}:#{login} #{home_path}`
  end

  def home_path
    "/home/#{login}"
  end

  def authorized_keys_path
    "#{home_path}/.ssh/authorized_keys"
  end

  private
  def success?
    ($?.exitstatus == 0)
  end
end

##
# Need to run as root/sudo
#
if `id -u` == '0'
  puts "Please run as root/sudo"
  return 1
end

if ENV['PROJECT'].nil? || ENV['PROJECT'] == ''
  puts "Please specify the project"
  return 1
end

##
# Check for the sudo group, add if it doesn't exist.
#
`egrep -q ^sudo /etc/group`
`groupadd sudo` unless ($?.exitstatus == 0)

##
# Check for correct sudoer line, add if it doesn't exist.
#
`grep -q '%sudo   ALL=NOPASSWD: ALL' /etc/sudoers`
`echo '%sudo   ALL=NOPASSWD: ALL' >> /etc/sudoers` unless ($?.exitstatus == 0)

##
# Check for the envylabs group, add if it doesn't exist.
#
`egrep -q ^envylabs_accounts /etc/group`
`groupadd envylabs_accounts` unless ($?.exitstatus == 0)

ShellUser.manage(ENV['PROJECT'].to_s.strip.downcase)
