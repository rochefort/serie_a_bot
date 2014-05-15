Dir.glob(File.join(File.expand_path('config/initializers'), '*.rb')).each do |f|
  require f
end
