# -*- encoding: utf-8 -*-
require File.expand_path('../lib/plastic_cup/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'plastic_cup'
  gem.version       = PlasticCup::VERSION
  gem.licenses      = ['BSD']

  gem.authors  = ['April Tsang']

  gem.description = <<-DESC
Plastic Cup is a simplified version of Teacup, aiming at memory leak prevention.
It allow assigning properties to object by hash and define stylesheets, in a dummy way.
  DESC

  gem.summary = 'A rubymotion gem for assigning properties to object by hash.'
  gem.homepage = 'https://github.com/apriltg/plastic_cup'

  gem.files       = `git ls-files`.split($\)
  gem.require_paths = ['lib']
  gem.test_files  = gem.files.grep(%r{^spec/})
end
