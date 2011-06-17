module Keymaster

  ##
  # Returns the current version number of the application.
  #
  def self.version
    @@version ||= Rails.root.join('VERSION').read.strip
  end

  ##
  # Returns the data (content) for the gatekeeper.rb file to be executed by
  # the servers.
  #
  def self.gatekeeper_data
    @@gatekeeper_data ||= Rails.root.join('lib/gatekeeper.rb').read.
      gsub('%CURRENT_KEYMASTER_VERSION%', self.version).
      gsub('%CURRENT_PUBLIC_KEY%', ENV['PUBLIC_SIGNING_KEY'])
  end

end
