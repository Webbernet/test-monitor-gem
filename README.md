# Test Recorder Ruby Client

The Test Recorder client sends test metrics

## Installation

Add this line to your application's Gemfile:

```ruby
gem "test_recorder_ruby", git: 'https://github.com/Webbernet/test-monitor-gem'
```

And then execute:

    $ bundle

## Usage

Run it via command line

```shell
bundle exec rspec --format TestRecorder::Formatter
```
or include it in your spec_helper.rb

```
config.formatter = TestRecorder::Formatter
```

Two environment variables should be available. By default the formatter does nothing unless specifically enabled, and also you need to add your unique project secret.

```shell
export RUN_TEST_MONITOR=true
export TEST_MONITOR_SECRET=12endj13rfn1jfasda
```



