module ServiceObject
  require 'delegate'

  class Errors < Delegator
    # @return [Array] Messages of the current errors
    attr_reader :messages

    def initialize
      @messages = []
    end

    def __getobj__
      @messages
    end

    # Return all the current error messages
    # @return [Array] Messages of the current errors
    def full_messages
      messages
    end

    # Add a new error message to the current error messages
    # @param message [String] New error message to add
    def add(message)
      @messages << message
    end

    class << self

      # Change activemodel errors into a string to be added to service errors
      # @param active_model [ActiveModel] ActiveModel Object
      #   whose error messages are to be flattened
      # @return [String] Flattened string error message
      def flattened_active_model_error(active_model)
        "#{active_model.class}: #{active_model.errors.full_messages.join(', ')}"
      end
    end
  end
end
