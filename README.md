# ServiceObject for Ruby on Rails

A mini gem to make it easy for you to have service objects in Rails.

This gem allows your controllers to control only flows and encapsulates detailed logic in services.

```ruby
  def some_action_on_book
    service = CreateMyBookService.new(params[:isbn])
    service.run do |s|
      s.get_info_from_isbn_api
      s.get_availability_with_library
      s.save_my_book
    end
    if service.result
      render json: { result: 'success', message: 'Successfully saved the book data' }
    else
      render json: { result: 'failure', messages: service.error_messages }
    end
  end
```

[Rails Cast (Pro): #398 Service Objects](http://railscasts.com/episodes/398-service-objects)

[![Code Climate](https://codeclimate.com/github/untidy-hair/service_object/badges/gpa.svg)](https://codeclimate.com/github/untidy-hair/service_object)
[![Build Status](https://travis-ci.org/untidy-hair/service_object.svg?branch=ci-setup)](https://travis-ci.org/untidy-hair/service_object)

## Install
In your Rails application Gemfile, add this line and do 'bundle install'
```ruby
gem 'service_object'
```

## Usage (What you need to know)
1. How to implement your code
  - Inherit ServiceObject::Base in your service class.
  - Your service class needs to call `super` in its initializer for now.
  - Define your methods in the service.
  - Make your service method raise an error whenever it fails. 
  (By default, ServiceObject::Base\#result will return false and ServiceObject::Base\#error_messages will have error message.)
  - For error cases, override and customize ServiceObject::Base\#process_exception(e) to handle exceptions in your own way. 
  As a best practice, process only expected errors but re-raise unexpected errors. (See Sample 2 below)
  By default, all `StandardError` will be caught and the error messages will be stored in `@errors` that thus will be accessible through `#error_messages`.
  - Implement your controller with `run` or `execute` method and put your service methods inside the block.

2. Interfaces for controllers
  - ServiceObject::Base\#run(#execute): Put your service methods in order in the \#run block. (See samples below.)
  - ServiceObject::Base\#result: If all the service process goes well, it returns true.
Otherwise it returns false.
  - ServiceObject::Base\#error_messages: Returns an array of error messages.

3. Other utility methods
  - ServiceObject::Base\#logger is available (delegated to Rails.logger)
  - ServiceObject::Base\#transaction is available (delegated to ActiveRecord::Base.transaction)
  - ServiceObject::Base\#flattened_active_model_error(private) changes ActiveModel error
to a string so that the error gets easy to add to `@errors`


## Sample 1

### Controller
Your controller will be well-readable and the flow is easy to understand.
You can use \#result or \#error_messages to know the result of your service.

```ruby
  def some_action_on_book
    service = CreateMyBookService.new(params[:isbn])
    service.run do |s|
      s.get_info_from_isbn_api
      s.get_availability_with_library
      s.save_my_book
    end
    if service.result
      render json: { result: 'success', message: 'Successfully saved the book data' }
    else
      render json: { result: 'failure', messages: service.error_messages }
    end
  end
```

### Service
Inherit ServiceObject::Base and implement business logic into methods.
When something goes wrong, throw an error from inside your method in service.
The process stops there and the error will be added to service.errors (available through service.error_messages) and service.result returns false automatically.
```ruby
class CreateMyBookService < ServiceObject::Base
  def initialize(isbn)
    super # This is necessary
    @isbn = isbn
    @book_info = nil
    @my_book = MyBook.new # ActiveRecord Model
    @isbn_api = IsbnApi.new(@isbn) # Non-AR Model
    @library_api = LibraryApi.new # Non-AR Model
  end

  def get_info_from_isbn_api
    @book_info = @isbn_api.get_all_info
  end

  def get_availability_with_library
    @availability = @library_api.get_availability(@isbn)
  rescue Net::HTTPError => e
    # You can re-throw you own error, too.
    raise YourError, 'Failed to get availability from library'
  end

  def save_my_book
    @my_book.update!(
      available: @availability,
      name: @book_info.title,
      author: @book_info.author,
      isbn: @isbn
     )
  end
end
```

## Sample 2

A sample with DB transaction and rollback process.

### Controller
```ruby
  def some_action_on_content_file
    service = UploadContentService.new(content_params, session[:user_id])
    service.execute do |s| # execute is alias of #run
      s.upload_file
      s.transaction do
        s.save_content_data
        s.update_user
      end
    end

    if service.executed_successfully? # executed_successfully is alias of #result
      render json: { result: 'success', message: 'Successfully uploaded your content' }
    else
      render json: { result: 'failure', messages: service.error_messages }
    end
  end
```

### Service

```ruby
class UploadContentService < ServiceObject::Base
  def initialize(params, user_id)
    super
    @content = Content.new(params)
    @file = ContentFile.new(params[:file_path])
    @user = User.find(user_id)
  end

  def upload_file
    raise YourFileError, "File Type needs to be one of #{ContentFile::TYPES.join('/')}" unless @file.allowed_file_type?
    @file.build_permission_info
    @file.queue_upload_job! # Let's assume this throws ContentFile::YourOwnEnqueueError when failing.
  end

  def save_content_data
    @content.update!(active: true)
  end

  def update_user
    @user.contents_counter += 1 # This is just a contrived sample. Use counter_cache
    @user.save!
  end

  # Custom error process by overriding the originally defined #process_exception.
  def process_exception(e)
    if e.is_a? ActiveRecord::ActiveRecordError 
      # When DB persistence fails, revert uploading file, too.
      rollback_uploaded_file
      @errors.add flattened_active_model_error(e.record) # This method is provided for convenience
    elsif e.class.in? [ContentFile::YourOwnEnqueueError, YourFileError]
      # This is still known error.
      logger.warn 'File upload had an issue.'
      @errors.add e.message
    else
      # Other errors are unexpected, so let the system fail by re-raising the error. 
      raise e  
    end
  end
  
  def rollback_uploaded_file
    if @file.respond_to?(:queued?) && @file.queued?
      @file.delete_queue_job
    end
  end
end
```

## More Flow Controls (hooks)
- Override `before_run` method if there are pre-processes that you don't want to show in your controller.
- Override `after_run` method if there are post-processes that you don't want to show in your controller.

## To Do
- Integration tests / Tests for each use case

## Credits

ServiceObject is written by untidyhair(Yukio Mizuta).

## License

[MIT-LICENSE](MIT-LICENSE)
