module ServiceObject
  require 'delegate'

  class Errors < Delegator
    attr_reader :messages

    def initialize
      @messages = []
    end

    def __getobj__
      @messages
    end

    def full_messages
      messages
    end

    def add(message)
      @messages << message
    end

    class << self

      def flattened_active_model_error(active_model)
        "#{active_model.class}: #{active_model.errors.full_messages.join(', ')}"
      end
    end
  end
end
