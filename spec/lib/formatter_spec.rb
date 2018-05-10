describe TestMonitor::Formatter do
  include FormatterSupport

  before do
    stub_const('TestMonitor::Formatter::LOGS_ENABLED', false)
  end

  describe '#dump_summary' do
    it 'prints the standard report' do
      notification = summary_notification(examples(1), examples(1), examples(1))
      send_notification :dump_summary, notification
      expect(formatter_output.string).to match(
        '1 example, 1 failure, 1 pending'
      )
    end

    it 'sets :summary field of output_hash' do
      notification = summary_notification(examples(1), examples(1), examples(1))
      send_notification :dump_summary, notification
      expected = {
        duration: 0,
        example_count: 1,
        failure_count: 1,
        pending_count: 1
      }
      expect(formatter.output_hash[:summary]).to eq expected
    end
  end

  describe '#stop' do
    let(:now) { Time.now }

    before do
      allow(Time).to receive(:now).and_return(now)
    end

    it 'sets :examples field of output_hash' do
      reporter.example_started new_passed_example('./spec/passed_spec.rb', 3)
      send_notification :stop, stop_notification

      run_times = get_runtimes(formatter)
      timestamp = now.to_i

      expected = [
        new_passed_example_hash(
          './spec/passed_spec.rb', 3, run_times[0], timestamp
        )
      ]

      expect(formatter.output_hash[:examples]).to eq expected
    end
  end

  describe '#close' do
    it 'prints the standard report' do
      stub_request(:post, TestMonitor::Formatter::NOTIFICATION_URL)
        .to_return(status: 200, body: '', headers: {})
      send_notification :close, null_notification

      expect(formatter_output.string).to eq ""
    end

    context 'when reports are enabled' do
      let(:passed_example) do
        new_passed_example('./spec/passed_spec.rb', 3)
      end
      let(:failed_example) do
        new_failed_example('./spec/failed_spec.rb', 7)
      end
      let(:now) { Time.now }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('RUN_TEST_MONITOR').and_return('true')
        allow(Time).to receive(:now).and_return(now)

        notification = summary_notification(
          [passed_example], [failed_example], []
        )
        send_notification :dump_summary, notification

        reporter.example_started passed_example
        reporter.example_started failed_example
        send_notification :stop, stop_notification
      end

      it 'sends a JSON report' do
        run_times = get_runtimes(formatter)
        timestamp = now.to_i

        examples = [
          new_passed_example_hash(
            './spec/passed_spec.rb', 3, run_times[0], timestamp
          ),
          new_failed_example_hash(
            './spec/failed_spec.rb', 7, run_times[1], timestamp
          )
        ]
        body = {
          examples: examples,
          summary: {
            duration: 0,
            example_count: 1,
            failure_count: 1,
            pending_count: 0
          },
          summary_line: '1 example, 1 failure'
        }

        stub_request(:post, TestMonitor::Formatter::NOTIFICATION_URL)
          .with(body: body)
          .to_return(status: 200, body: '', headers: {})

        send_notification :close, null_notification
      end

      context 'when request fails' do
        it 'raises an exception' do
          stub_request(:post, TestMonitor::Formatter::NOTIFICATION_URL)
            .with(body: {})
            .to_return(status: 404, body: 'Not found', headers: {})

          expect do
            send_notification :close, null_notification
          end.to raise_error(RestClient::NotFound, '404 Not Found')
        end
      end
    end

    context 'when reports are disabled' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('RUN_TEST_MONITOR').and_return(nil)
      end

      it 'does not send any requsts' do
        send_notification :close, null_notification

        expect(WebMock).not_to have_requested(
          :post, TestMonitor::Formatter::NOTIFICATION_URL
        )
      end
    end
  end

  describe '#seed' do
    context 'use random seed' do
      it 'adds random seed' do
        send_notification :seed, seed_notification(42)
        expect(formatter.output_hash[:seed]).to eq(42)
      end
    end

    context 'do not use random seed' do
      it 'does not add random seed' do
        send_notification :seed, seed_notification(42, false)
        expect(formatter.output_hash[:seed]).to be_nil
      end
    end
  end

  def new_passed_example_hash(path, line_number, run_time, timestamp)
    new_example_hash('passed', path, line_number, run_time, timestamp)
  end

  def new_failed_example_hash(path, line_number, run_time, timestamp)
    new_example_hash('failed', path, line_number, run_time, timestamp).merge(
      exception: {
        class: 'Exception',
        message: 'Uh oh',
        backtrace: nil
      }
    )
  end

  def new_pending_example_hash(path, line_number, run_time, timestamp)
    new_example_hash('pending', path, line_number, run_time, timestamp)
  end

  def new_example_hash(status, path, line_number, run_time, timestamp)
    {
      status: status,
      description: 'Example',
      full_description: 'Example',
      file_path: path,
      line_number: line_number,
      run_time: run_time,
      timestamp: timestamp
    }
  end

  def get_runtimes(formatter)
    formatter.output_hash[:examples].map do |example|
      example[:run_time]
    end
  end
end