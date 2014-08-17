module ServiceObject
  class Base
    attr_reader :errors

    def initialize
      @result = true
      @errors = Errors.new
    end

    def error_messages
      @errors.full_messages
    end

    def result
      @result && @errors.empty?
    end
  end
end
