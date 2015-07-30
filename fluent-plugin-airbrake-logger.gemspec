# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-airbrake-logger"
  spec.version       = "0.0.2"
  spec.authors       = ["Shuichi Ohsawa"]
  spec.email         = ["ohsawa0515@gmail.com"]

  spec.summary       = %q{Output filter plugin to Airbrake(Errbit) by fluent-logger}
  spec.description   = %q{Output filter plugin to Airbrake(Errbit) by fluent-logger}
  spec.homepage      = "https://github.com/ohsawa0515/fluent-plugin-airbrake-logger"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($\)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fluentd"
  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "airbrake", ">= 4.3.0"
end
