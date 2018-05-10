
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'test_recorder/version'

Gem::Specification.new do |spec|
  spec.name          = 'test_recorder_ruby'
  spec.version       = TestRecorder::VERSION
  spec.authors       = ['Ivan Kuznetsov']
  spec.email         = ['me@jeiwan.ru']

  spec.summary       = 'JSON formatter for RSpec with notification'
  spec.description   = 'JSON formatter for RSpec with notification'
  spec.homepage      = 'https://github.com/Webbernet/test-monitor-gem'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://github.com'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'webmock', '~> 3.4.1'
  spec.add_dependency 'rest-client', '~> 2.0.2'
  spec.add_dependency 'rspec', '~> 3.5.0'
end
