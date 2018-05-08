require "rspec"

module TestMonitor
  class Formatter < RSpec::Core::Formatters::ProgressFormatter
    RSpec::Core::Formatters.register self, :dump_summary

    def dump_summary(summary)
      super(summary)
      puts("Hello from TestMonitor")
    end
  end
end