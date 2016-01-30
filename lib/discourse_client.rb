require 'discourse_api'

class DiscourseClient < DiscourseApi::Client
  class Error < StandardError
    attr_reader :wrapped_exception

    def initialize(exception=$!)
      @wrapped_exception = exception
      exception.respond_to?(:message) ? super(exception.message) : super(exception.to_s)
    end
  end

  def create_topic(args={})
    begin
      super(args)
    rescue DiscourseApi::Error => e
       raise Error.new(e)
    end
  end
end