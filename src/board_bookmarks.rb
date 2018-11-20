require 'json'

class BoardBookmarks
  attr_accessor :bookmarks_file_path, :bookmarks

  def initialize(bookmarks_file_path:)
    @bookmarks_file_path = bookmarks_file_path
    @bookmarks = load_bookmarks
  end

  def get_pin(board_id:)
    @bookmarks[board_id]['pin_id']
  end

  def set_pin(board_id:, pin_id:)
    board_bookmark = {pin_id: pin_id}
    @bookmarks[board_id] = board_bookmark
  end

  def save
    bookmarks_data = @bookmarks.to_json
    puts "\tSaving sync bookmarks to #{@bookmarks_file_path}"

    File.open(bookmarks_filename, 'w') do |bookmarks_file|
      bookmarks_file << bookmarks_data
    end
  end

  private

  def load_bookmarks
    puts 'loading bookmarks'
    @bookmarks = load_bookmarks_file
  end

  def load_bookmarks_file
    return {} unless File.exists?(bookmarks_filename)

    bookmarks_json = File.read(bookmarks_filename)
    JSON.parse(bookmarks_json)
  end

  def bookmarks_filename
    @bookmarks_file_path + '/sync_bookmarks.json'
  end
end
