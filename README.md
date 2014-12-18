# ServiceObject

ServiceObject provides conventions and utilities to Service objects in your Rails
application.

Not only does it let you code complicated business logic easier, but it also helps you
keep controllers well-readable and models loose-coupled to each other.

## Install
In your Rails application Gemfile, add this line and do 'bundle install'
```ruby
gem 'service_object'
```

## Usage (What you need to know)
1. Interfaces for controllers
  - ServiceObject::Base\#result: If all the service process goes well so far, it returns true.
Otherwise it returns false.
  - ServiceObject::Base\#error_messages: Returns an array of error messages.

2. Conventions
  - Inherit ServiceObject::Base in your service class.
  - Your service class needs to call "super()" in its initializer for now. (This may be changed in the future.)
  - Change @result to false in service object whenever your service fails.
  - Add an error string to @errors in service object whenever your service fails.

3. Other utility methods
  - ServiceObject::Base\#logger is delegated to Rails.logger
  - ServiceObject::Base\#transaction is delegated to ActiveRecord::Base.transaction
  - ServiceObject::Base\#flattened_active_model_error(private) changes ActiveModel error
to a string so that the error gets easy to add to @errors


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

  def log_exception(exception, log_level = :warn, logger = logger)
    logger.__send__(log_level.to_sym, "#{exception.class}: #{exception.message}")
    logger.__send__(log_level.to_sym, exception.backtrace)
  end
end
```

### Controller
Your controller will be well-readable and the flow is easy to understand.
You can use \#result or \#error_messages to know the result of your service.

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

```ruby
  # UploadContentService
  def upload_file
    # Do something with UserFile non-AR model
  end

  def save_content_data
    # Do something with Content model (with save!)
  end

  def update_user
    # Do something with User model (with save!)
  end

  def rollback_transaction(e)
    logger.warn "[#{e.class}] #{e.message}"
    rollback_uploaded_file
    @errors.add 'Failed to update database'
    @result = false
  end

  def rollback_uploaded_file
    # Do something to delete the uploaded file
  end
```

### Controller
```ruby
  def some_action_on_content_file
    service = UploadContentService.new(params)
    service.transaction do
      service.upload_file &&
      service.save_content_data &&
      service.update_user
    end
    if service.result
      render json { result: 'success', message: 'Successfully uploaded your content' }
    else
      render json: { result: 'failure', messages: service.error_messages }
    end
  rescue => ActiveRecord::ActiveRecordError => e
    service.rollback_transaction(e)
    render json: { result: 'failure', messages: service.error_messages }
  end
```

## To Do
- Poor document now
- Integration tests / Tests for each use case

## Credits

ServiceObject is written by untidyhair(Yukio Mizuta).

## License

[MIT-LICENSE](MIT-LICENSE)
