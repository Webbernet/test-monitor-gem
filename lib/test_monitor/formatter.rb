require "rspec"

module TestMonitor
  class Formatter < RSpec::Core::Formatters::ProgressFormatter
    def dump_summary(summary)
      super(summary)
      puts("Hello from TestMonitor")
    end
  end
end