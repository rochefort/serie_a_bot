PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

initializers_path = File.join(PROJECT_ROOT, 'config/initializers')
Dir.glob(File.join(initializers_path, '*.rb')).each do |f|
  require f
end
