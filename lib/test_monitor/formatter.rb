require 'rspec'
require 'json'
require 'rest-client'

module TestMonitor
  # Implements an RSpec formatter that sends JSON reports
  class Formatter < RSpec::Core::Formatters::ProgressFormatter
    RSpec::Core::Formatters.register self, :dump_summary, :stop, :seed, :close
    NOTIFICATION_URL = ENV['NOTIFICATION_URL'] || "http://localhost:3000/#{ENV['TEST_MONITOR_SECRET']}"
    LOGS_ENABLED = true

    attr_reader :output_hash

    def initialize(output)
      super
      @output_hash = {}
    end

    def dump_summary(summary)
      super(summary)

      @output_hash[:summary] = {
        duration: summary.duration,
        example_count: summary.example_count,
        failure_count: summary.failure_count,
        pending_count: summary.pending_count,
        errors_outside_of_examples_count: summary.errors_outside_of_examples_count # rubocop:disable Metrics/LineLength
      }
      @output_hash[:summary_line] = summary.totals_line
    end

    def stop(notification)
      @output_hash[:examples] = notification.examples.map do |example|
        format_example(example)
      end
    end

    def seed(notification)
      super(notification)

      return unless notification.seed_used?
      @output_hash[:seed] = notification.seed
    end

    def close(notification)
      super(notification)

      if reports_enabled?
        log 'Sending a JSON report...'
        post_json NOTIFICATION_URL, @output_hash.to_json
        log 'Done.'
        return
      end
      log 'Skipping JSON report.'
    end

    private

    def format_example(example)
      add_exception(build_example(example), example)
    end

    def build_example(example)
      {
        status: example.execution_result.status.to_s,
        description: example.description,
        full_description: example.full_description,
        file_path: example.metadata[:file_path],
        line_number: example.metadata[:line_number],
        run_time: example.execution_result.run_time,
        timestamp: Time.now.to_i
      }
    end

    def add_exception(example_hash, example)
      example_hash.tap do |hash|
        e = example.exception
        if e
          hash[:exception] = {
            class: e.class.name,
            message: e.message,
            backtrace: e.backtrace
          }
        end
      end
    end

    def log(message)
      puts message if LOGS_ENABLED
    end

    def reports_enabled?
      !ENV['RUN_TEST_MONITOR'].nil?
    end

    def post_json(url, payload)
      RestClient.post(url, payload, content_type: :json, accept: :json)
    end
  end
end
