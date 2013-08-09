require 'yaml'

ActionController::Renderers.add(:yaml) do |yaml, options|
  self.content_type ||= Mime::YAML
  yaml.respond_to?(:to_yaml) ? yaml.to_yaml(options) : yaml
end
