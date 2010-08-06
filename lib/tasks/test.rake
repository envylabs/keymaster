namespace :test do
  namespace :ci do
    desc "Configure the CI test server"
    task :configure do
      root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
      cp File.join(root, 'config/database.ci.yml'), File.join(root, 'config/database.yml')
    end
  end
end
