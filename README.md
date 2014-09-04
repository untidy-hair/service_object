# ServiceObject

ServiceObject provides conventions and utility to Service objects in your Rails
application.

Not only does it let you code complicated business logic easier, it also helps you
keep controllers well-readable and models single-responsible.

## Install
```ruby
gem 'service_object', :git => 'https://github.com/untidy-hair/service_object.git'
```

## Sample 1

### Service
Inherit ServiceObject::Base and implement each business logic.

It is recommended that each method returns true or false so that the controller
can control the flow easily.
When something went wrong, add the error message to @error and make @result = false.

```ruby
class CreateMyBookService < ServiceObject::Base
  def initialize(isbn)
    super()
    @isbn = isbn
    @book_info = nil
    @my_book = MyBook.new # ActiveRecord Model
    @isbn_api = IsbnApi.new(@isbn) # Non-AR Model
    @library_api = LibraryApi.new # Non-AR Model
  end

  def get_info_from_isbn_api
    @book_info = @isbn_api.get_all_info
    true
  rescue => e
    log_exception(e)
    @errors.add 'Failed to get info from isbn api'
    @result = false
  end

  def get_availability_with_library
    @availability = @library_api.get_avilability(@isbn)
    true
  rescue => e
    log_exception(e)
    @errors.add 'Failed to get availability from library'
    @result = false
  end

  def save_my_book
    @my_book.available = @availability
    @my_book.name = @book_info.title
    @my_book.author = @book_info.author
    @my_book.isbn = @isbn
    if @my_book.save
      true
    else
      Rails.logger.warn(@my_book.errors.full_messages.inspect)
      @errors.add 'Failed to save Mybook'
      @result = false
    end
  end

  private

  def log_exception(exception, log_level = :warn, logger = Rails.logger)
    logger.__send__(log_level.to_sym, "#{exception.class}: #{exception.message}")
    logger.__send__(log_level.to_sym, exception.backtrace)
  end
end
```

### Controller
Your controller will be well-readable and easy to understand the flow.

```ruby
  def some_action_on_book
    service = CreateMyBookService.new(params[:isbn])
    service.get_info_from_isbn_api &&
    service.get_availability_with_library &&
    service.save_my_book
    if service.result
      render json { result: 'success', message: 'Save the book data' }
    else
      render json: { result: 'failure', messages: service.error_messages }
    end
  end
```

## Sample 2

### Service
A sample which uses DB transaction.
("transaction" method is actually ActiveRecord::Base.transaction.)

```ruby
  # UploadContentService
  def upload_file
    # Do something with UserFile non-AR model
  end

  def save_content_and_update_user
    transaction do
      save_content
      update_user
    end
    true
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.warn "[#{e.class}] #{e.message}"
    rollback_uploaded_file
    @errors.add 'Failed to update database'
    @result = false
  end

  def save_content_data
    # Do something with Content model (with save!)
  end

  def update_user
    # Do something with User model (with save!)
  end

  def rollback_uploaded_file
    # Delete uploaded file or others
  end
```

### Controller
```ruby
  def some_action_on_content_file
    service = UploadContentService.new(params)
    service.upload_file &&
    service.save_content_and_update_user
    if service.result
      render json { result: 'success', message: 'Successfully uploaded your content' }
    else
      render json: { result: 'failure', messages: service.error_messages }
    end
  end
```

## Credits

ServiceObject is written by untidyhair(Yukio Mizuta).

## License

[MIT-LICENSE](MIT-LICENSE)
