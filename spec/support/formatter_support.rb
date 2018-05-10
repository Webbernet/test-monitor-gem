# Holds methods that help to manipulate with RSpec entities
module FormatterSupport
  def send_notification(type, notification)
    reporter.notify type, notification
  end

  def reporter
    @reporter ||= setup_reporter
  end

  def setup_reporter(*streams)
    streams << config.output_stream if streams.empty?
    config.formatter_loader.add described_class, *streams
    @formatter = config.formatters.first
    @reporter = config.reporter
  end

  def formatter_output
    @formatter_output ||= StringIO.new
  end

  def config
    @config ||=
      begin
        config = RSpec::Core::Configuration.new
        config.output_stream = formatter_output
        config
      end
  end

  def configure
    yield config
  end

  def formatter
    @formatter ||=
      begin
        setup_reporter
        @formatter
      end
  end

  def new_example(metadata = {})
    mock_example(group, execute_example(metadata), metadata)
  end

  def execute_example(metadata)
    metadata = metadata.dup
    result = RSpec::Core::Example::ExecutionResult.new
    result.started_at = ::Time.now
    result.record_finished(metadata.delete(:status) { :passed }, ::Time.now)
    result.exception = Exception.new('Uh oh') if result.status == :failed
    result
  end

  def mock_example(group, result, metadata)
    instance_double(
      RSpec::Core::Example,
      mock_example_data(group, result, metadata)
    )
  end

  def mock_example_data(group, result, metadata)
    {
      description: 'Example',
      full_description: 'Example',
      example_group: group,
      execution_result: result,
      location: '',
      location_rerun_argument: '',
      exception: result.exception,
      metadata: { shared_group_inclusion_backtrace: [] }.merge(metadata)
    }
  end

  def examples(count)
    Array.new(count) { new_example }
  end

  def group
    group = class_double 'RSpec::Core::ExampleGroup', description: 'Group'
    allow(group).to receive(:parent_groups) { [group] }
    group
  end

  def null_notification
    ::RSpec::Core::Notifications::NullNotification
  end

  def stop_notification
    ::RSpec::Core::Notifications::ExamplesNotification.new reporter
  end

  def summary_notification(examples, failed, pending)
    ::RSpec::Core::Notifications::SummaryNotification.new(
      0, examples, failed, pending, 0
    )
  end

  def seed_notification(seed, used = true)
    ::RSpec::Core::Notifications::SeedNotification.new seed, used
  end

  def new_passed_example(path, line_number)
    new_example(status: :passed, file_path: path, line_number: line_number)
  end

  def new_failed_example(path, line_number)
    new_example(status: :failed, file_path: path, line_number: line_number)
  end

  def new_pending_example(path, line_number)
    new_example(status: :pending, file_path: path, line_number: line_number)
  end
end
