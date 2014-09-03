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

    # Shorthand for ActiveRecord::Base.transaction
    def transaction(&block)
      self.class.transaction(&block)
    end

    class << self

      # Shorthand for ActiveRecord::Base.transaction
      def transaction(&block)
        ActiveRecord::Base.transaction(&block)
      end
    end

    private

    # Change activemodel errors into a string to be added to service errors
    # @param active_model [ActiveModel] ActiveModel Object
    #   whose error messages are to be flattened
    # @return [String] Flattened string error message
    def flattened_active_model_error(active_model)
      "#{active_model.class}: #{active_model.errors.full_messages.join(', ')}"
    end
  end
end
