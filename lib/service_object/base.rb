module ServiceObject
  # Service object base class which provides interfaces to controllers so that
  # they can access the result of service processing and its errors if any.
  # Uses ServiceObject::Errors as the error container.
  class Base
    # @return [ServiceObject::Errors] Errors object of the current service
    attr_reader :errors

    def initialize
      @result = true
      @errors = Errors.new
    end

    # Error messages of the service process so far
    # @return [Array] Array of error messages
    def error_messages
      @errors.full_messages
    end

    # Check if the service process is going well or not so far
    # @return [true, false]
    def result
      @result && @errors.empty?
    end
  end
end
