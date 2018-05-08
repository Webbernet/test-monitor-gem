describe TestMonitor::Formatter do
  include FormatterSupport

  describe '#dump_summary' do
    it 'prints the standard report' do
      send_notification :dump_summary, summary_notification(0, examples(1), examples(1), examples(1), 0)
      expect(formatter_output.string).to match("1 example, 1 failure, 1 pending")
    end

    it 'sets :summary field of output_hash' do
      send_notification :dump_summary, summary_notification(0, examples(1), examples(1), examples(1), 0)
      expected = {
        duration: 0,
        errors_outside_of_examples_count: 0,
        example_count: 1,
        failure_count: 1,
        pending_count: 1
      }
      expect(formatter.output_hash[:summary]).to eq expected
    end
  end
end