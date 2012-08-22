# -*- encoding: utf-8 -*-
require File.expand_path('../lib/octomine/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Anton Minin"]
  gem.email         = ["anton.a.minin@gmail.com"]
  gem.description   = %q{Redmine plugin for import issues from GitHub}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/aminin/octomine"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "octomine"
  gem.require_paths = ["lib"]
  gem.version       = Octomine::VERSION

  gem.add_dependency 'octokit'
end
