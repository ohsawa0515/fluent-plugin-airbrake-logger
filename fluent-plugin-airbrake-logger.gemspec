# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-airbrake-logger"
  spec.version       = "0.1.0"
  spec.authors       = ["Shuichi Ohsawa"]
  spec.email         = ["ohsawa0515@gmail.com"]

  spec.description   = %q{Fluent output plugin to Airbrake(Errbit) by fluent-logger}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/ohsawa0515/fluent-plugin-airbrake-logger"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($\)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "fluentd", ">= 0.12.0", "< 1"
  spec.add_development_dependency "airbrake", "~> 4.3.0"
  spec.add_runtime_dependency "fluentd", ">= 0.12.0", "< 1"
  spec.add_runtime_dependency "airbrake", "~> 4.3.0"

  spec.required_ruby_version = '>= 2.1'
end
