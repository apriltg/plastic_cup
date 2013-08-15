$:.unshift('/Library/RubyMotion/lib')
if ENV.fetch('platform', 'ios') == 'ios'
  require 'motion/project/template/ios'
elsif ENV['platform'] == 'osx'
  require 'motion/project/template/osx'
else
  raise "Unsupported platform #{ENV['platform']}"
end
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'plastic cup'
  app.identifier = 'com.tofugear.plasticcup'
  app.specs_dir = "spec/"
end
