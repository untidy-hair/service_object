require 'active_support/core_ext/module/delegation'
module ServiceObject
  # Service object base class which provides interfaces to controllers so that
  # they can access the result of service processing and its errors if any.
  # Uses ServiceObject::Errors as the error container.
  class Base
    # @return [ServiceObject::Errors] Errors object of the current service
    attr_reader :errors
    delegate :logger, to: :Rails

    def initialize(*args)
      @result = true
      @errors = Errors.new
    end

    # This runs your logic without exposing unessential processes to your controllers.
    # @return [true, false]
    #
    # Examples:
    # # Controller
    #  def some_action_on_book
    #    service = CreateMyBookService.new(params[:isbn])
    #    service.run do |s|
    #      s.get_info_from_isbn_api
    #      s.get_availability_with_library
    #      s.save_my_book
    #    end
    #    if service.result
    #      render json: { result: 'success', message: 'Successfully saved the book data' }
    #    else
    #      render json: { result: 'failure', messages: service.error_messages }
    #    end
    #  end
    #
    # # Service
    # class CreateMyBookService < ServiceObject::Base
    #   def initialize(isbn)
    #     super # This is necessary
    #     @isbn = isbn
    #     @book_info = nil
    #     @my_book = MyBook.new # ActiveRecord Model
    #     @isbn_api = IsbnApi.new(@isbn) # Non-AR Model
    #     @library_api = LibraryApi.new # Non-AR Model
    #   end
    #
    #   def get_info_from_isbn_api
    #     @book_info = @isbn_api.get_all_info
    #   end
    #
    #   def get_availability_with_library
    #     @availability = @library_api.get_availability(@isbn)
    #   rescue Net::HTTPError => e
    #     # You can re-throw you own error, too.
    #     raise YourError, 'Failed to get availability from library'
    #   end
    #
    #   def save_my_book
    #     @my_book.update!(
    #         available: @availability,
    #         name: @book_info.title,
    #         author: @book_info.author,
    #         isbn: @isbn
    #    )
    #   end
    # end
    #
    def run
      before_run
      yield self
      after_run
      @result
    rescue => e
      process_exception(e)
      @result = false
    end
    alias execute run

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
    alias executed_successfully? result
    alias ran_successfully? result

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

    # Override this method when there are other pre-processes that you don't want to show in controller.
    def before_run; end

    # Override this method when there are other post-processes that you don't want to show in controller.
    def after_run; end

    # @param e [StandardError]
    # This puts all StandardError encountered into @errors, which will be available through #error_messages.
    # If you want to specify special behaviors for each error type such as some rollback process or error logging,
    # please override this method. (See README.md Sample 2.)
    def process_exception(e)
      @errors.add e.message
    end

    # Change activemodel errors into a string to be added to service errors
    # @param active_model [ActiveModel] ActiveModel Object
    #   whose error messages are to be flattened
    # @return [String] Flattened string error message
    def flattened_active_model_error(active_model)
      "#{active_model.class}: #{active_model.errors.full_messages.join(', ')}"
    end
  end
end
