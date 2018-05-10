# Test Recorder Ruby Client

The Test Recorder client sends test metrics

## Installation

Add this line to your application's Gemfile:

```ruby
gem "test_recorder_ruby", git: 'https://github.com/Webbernet/test-recorder-ruby'
```

And then execute:

    $ bundle

## Usage

Run it via command line

```shell
bundle exec rspec --format TestRecorder::Formatter
```

or set it in your .rspec:

```
--format TestRecorder::Formatter
```

or include it in your spec_helper.rb

```ruby
require 'test_recorder_ruby/formatter'

RSpec.configure do |config|
    config.formatter = TestRecorder::Formatter
    ...
end
```

Two environment variables should be available. By default the formatter does nothing unless specifically enabled, and also you need to add your unique project secret.

```shell
export RUN_TEST_MONITOR=true
export TEST_MONITOR_SECRET=12endj13rfn1jfasda
```

## Failure context

To report additional information about a failed example, pass a hash with `:context` key as the last argument to `describe`, `context`, or `it`:

```ruby
describe 'Failing spec' do
    variable = 'context data'

    it 'will fail', context: variable do
        expect(1).to eq 2
    end
end
```

When the test fails, the value of `:context` will be included in the JSON report.
