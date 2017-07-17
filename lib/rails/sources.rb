module Rails
  class Sources
    require_relative "sources/version"

    def self.establish(required: false, retries: 10, fallback: 30.seconds, global: true)
      connection || new(required: required, retries: retries, fallback: fallback, global: global).connection
    end

    def self.connection
      @connection
    end

    def self.connection=(value)
      @connection = value
    end

    def initialize(required:, retries:, fallback:, global:)
      return if global && self.class.connection

      @global = global

      self.connection = connect
    rescue StandardError => exception
      retries -= 1 unless required

      logger.error(exception)
      logger.debug(exception.backtrace.join("\n"))

      sleep(fallback) and retry if required || retries.zero?
    end

    def connection
      if @global
        self.class.connection
      else
        @connection
      end
    end

    def connection=(value)
      if @global
        self.class.connection = value
      else
        @connection = value
      end
    end

    private def open?
      raise NoMethodError, "missing implementation"
    end

    private def closed?
      !open?
    end

    private def connect
      raise NoMethodError, "missing implementation"
    end

    private def logger
      if Rails.logger then Rails.logger else Logger.new STDOUT end
    end
  end
end
