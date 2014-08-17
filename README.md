# ServiceObject

ServiceObject provides conventions and utility to Service objects in your Rails
application.

## Service
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
  rescue => e
    Rails.logger.warn("#{e.class}: #{e.message}")
    self.errors << 'Failed to get info from isbn api'
    @result = false
  end

  def get_availability_with_library
    @availability = @library_api.get_avilability(@isbn)
  rescue => e
    Rails.logger.warn("#{e.class}: #{e.message}")
    self.errors << 'Failed to get availability from library'
    @result = false
  end

  def save_my_book
    @my_book.availabile = @availability
    @my_book.name = @book_info.title
    @my_book.author = @book_info.author
    @my_book.isbn = @isbn
    if @my_book.save
      true
    else
      Rails.logger.warn(@my_book.errors.full_messages.inspect)
      self.errors << 'Failed to save Mybook'
      @result = false
    end
  end
end
```

## Controller
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

## Credits

ServiceObject is created by untidyhair(Yukio Mizuta).

## License

[MIT-LICENSE](MIT-LICENSE)
