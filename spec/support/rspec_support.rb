module RSpecSupport
  def newer_rspec_version?
    rspec_version = RSpec::Core::Version::STRING
    Gem::Version.new(rspec_version) >= Gem::Version.new('3.6.0')
  end
end
