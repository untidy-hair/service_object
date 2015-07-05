require 'active_support/core_ext/array/conversions'
require 'delegate'

module ServiceObject

  # Provides a customized +Array+ to contain errors that happen in service layer.
  # Also provides a utility APIs to handle errors well in controllers.
  # (All array methods are available by delegation, too.)
  #   errs = ServiceObject::Errors.new
  #   errs.add 'Something is wrong.'
  #   errs.add 'Another is wrong.'
  #   errs.messages
  #   => ['Something is wrong.','Another is wrong.']
  #   errs.full_messages
  #   => ['Something is wrong.','Another is wrong.']
  #   errs.to_xml
  #   => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>\n  <error>Something is wrong.</error>\n
  #  <error>Another is wrong.</error>\n</errors>\n"
  #   errs.empty?
  #   => false
  #   errs.clear
  #   => []
  #   errs.empty?
  #   => true
  class Errors < Delegator
    # @return [Array<String>] Messages of the current errors
    attr_reader :messages

    def initialize
      @messages = []
    end

    # @private
    def __getobj__ # :nodoc:
      @messages
    end

    # Returns all the current error messages
    # @return [Array<String>] Messages of the current errors
    def full_messages
      messages
    end

    # Adds a new error message to the current error messages
    # @param message [String] New error message to add
    def add(message)
      @messages << message
    end

    # Generates XML format errors
    #   errs = ServiceObject::Errors.new
    #   errs.add 'Something is wrong.'
    #   errs.add 'Another is wrong.'
    #   errs.to_xml
    #   =>
    #   <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    #    <errors>
    #      <error>Something is wrong.</error>
    #      <error>Another is wrong.</error>
    #    </errors>
    # @return [String] XML format string
    def to_xml(options={})
      super({ root: "errors", skip_types: true }.merge!(options))
    end

    # Generates duplication of the message
    # @return [Array<String>]
    def as_json
      messages.dup
    end
  end
end
