require 'time'
require 'json'
require_relative '../elastic_common_schema'

# Not Twilight ;)
module Twiglet
  class Logger
    include ElasticCommonSchema

    def initialize(conf:, scoped_properties: {})
      @service = conf[:service]
      @now = conf[:now] || -> { Time.now.utc }
      @output = conf[:output] || $stdout

      raise 'configuration must have a service name' \
        unless @service.is_a?(String) && @service.strip.length > 0

      @scoped_properties = scoped_properties
    end

    def debug(message)
      log(level: 'debug', message: message)
    end

    def info(message)
      log(level: 'info', message: message)
    end

    def warning(message)
      log(level: 'warning', message: message)
    end

    def error(message, error = nil)
      if error
        message = message.merge({
                                    error_name: error.message,
                                    backtrace: error.backtrace
                                })
      end

      log(level: 'error', message: message)
    end

    def critical(message)
      log(level: 'critical', message: message)
    end

    def with(scoped_properties)
      Logger.new(conf: {service: @service,
                        now: @now,
                        output: @output},
                 scoped_properties: scoped_properties)
    end

    private

    def log(level:, message:)
      raise 'Message must be a Hash' unless message.is_a?(Hash)

      message = message.transform_keys(&:to_sym)
      raise "Log object must have a 'message' property" unless message.key?(:message)
      raise "The 'message' property of log object must not be empty" unless message[:message].strip.length > 0

      total_message = ({
          service: {
              name: @service
          },
          "@timestamp": @now.call.iso8601(3),
          log: {
              level: level
          }
      })
                          .merge(@scoped_properties)
                          .merge(message)
                          .then { |log_entry| to_nested(log_entry) }

      @output.puts total_message.to_json
    end
  end
end
