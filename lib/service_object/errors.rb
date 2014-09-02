module ServiceObject
  require 'delegate'

  # Responsible for containing, providing and adding errors on service layer.
  # Also provides a utility to stringify active model errors.
  class Errors < Delegator
    # @return [Array<String>] Messages of the current errors
    attr_reader :messages

    def initialize
      @messages = []
    end

    def __getobj__
      @messages
    end

    # Return all the current error messages
    # @return [Array<String>] Messages of the current errors
    def full_messages
      messages
    end

    # Add a new error message to the current error messages
    # @param message [String] New error message to add
    def add(message)
      @messages << message
    end
  end
end
