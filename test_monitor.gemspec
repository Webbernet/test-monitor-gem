
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "test_monitor/version"

Gem::Specification.new do |spec|
  spec.name          = "test_monitor"
  spec.version       = TestMonitor::VERSION
  spec.authors       = ["Ivan Kuznetsov"]
  spec.email         = ["me@jeiwan.ru"]

  spec.summary       = %q{JSON formatter for RSpec with notification}
  spec.description   = %q{JSON formatter for RSpec with notification}
  spec.homepage      = "https://github.com/Webbernet/test-monitor-gem"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://github.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency "httparty", "~> 0.16.2"
end
