# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'day_planner/version'

Gem::Specification.new do |spec|
  spec.name          = "day_planner"
  spec.version       = DayPlanner::VERSION
  spec.authors       = ["Damon Siefert"]
  spec.email         = ["siefert@gmail.com"]
  spec.description   = %q{Simple gem to handle in-process scheduling of tasks}
  spec.summary       = %q{Built to have a way to schedule tasks without running an extra process and incurring extra costs on Heroku.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "activesupport", ">= 3.0.0"
  spec.add_dependency "rails", ">= 3.0.0"

  spec.required_ruby_version = ">= 1.9.0"
end
