namespace :test do
  namespace :ci do
    desc "Configure the CI test server"
    task :configure do
      require 'pathname'
      root = Pathname.new File.expand_path('../../../', __FILE__)
      cp root.join('config/database.ci.yml'), root.join('config/database.yml')
    end
  end
end
