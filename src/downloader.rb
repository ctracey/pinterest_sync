require 'digest'
require_relative 'board_bookmarks'

class Downloader

  attr_accessor :board, :successes, :failures, :download_folder, :total_new_pins, :board_bookmarks

  def initialize(board:, download_path:)
    @board = board
    @download_folder = setup_download_folder(download_path)
    @board.previous_synced_pin = board_bookmarks.get_pin(board_id: board.id)

    @failures = []
    @successes = 0
  end

  def setup_download_folder(path)
    Dir.mkdir(path) unless Dir.exists?(path)
    Dir.new(path)
  end

  def run
    synced = true
    @total_new_pins = 0
    begin
      board.load_pins

      puts "Syncing pinterest board"
      puts "\tunsynced pages found: #{board.page_count}"
      puts "\timages synced: #{board.image_count}"
      puts "\tlocal collection files: #{local_collection_size}"

      new_pins = find_new_pins
      @total_new_pins = new_pins.size
      puts "#{new_pins.size} new images to download"

      download_pins(new_pins)
      update_board_bookmarks
    rescue StandardError => e
      puts "Error: #{e.message}"
      puts e.backtrace
      synced = false
    end

    download_report(@total_new_pins)
    synced
  end

  private

  def board_pins
    @board_pins ||= board.pins
  end

  def find_new_pins
    new_images = []

    board_pins.each do |pin|
      filename = pin_filename(pin)
      new_images << pin unless image_downloaded?(filename)
    end

    new_images
  end

  def download_pins(pins)
    pins.each_with_index do |pin, i|
      filename = pin_filename(pin)
      unless image_downloaded?(filename)
        print image_progress(pin.url, i, pins.size)
        response_code = download_image(pin)
        puts response_code
      end
    end
  end

  def update_board_bookmarks
    puts 'Updating board bookmarks'
    board_bookmarks.set_pin(board_id: board.id, pin_id: board.most_recent_pin)
    board_bookmarks.save
  end

  def board_bookmarks
    @board_bookmarks ||= BoardBookmarks.new(bookmarks_file_path: download_folder.to_path)
  end

  def total_pins
    board_pins.size
  end

  def image_downloaded?(filename)
    File.exists?(filename)
  end

  def download_image(pin)
    filename = pin_filename(pin)

    img_response = get_image(pin.url)

    if img_response.code == 200
      save_image(img_response, filename)
      @successes += 1
    else
      @failures << pin.url
    end

    img_response.code
  end

  def get_image(url)
    HTTParty.get(url)
  end

  def image_progress(url, file_number, total_images)
    image = "\t#{file_number + 1}/#{total_images}"
    progress = "downloading #{url} ... "

    "#{image} #{progress}"
  end

  def save_image(response, filename)
    img = File.new(filename, 'w')
    img.write(response.body)
    img.close
  end

  def pin_filename(pin)
    extension = pin.url.match(/\.[a-z]*$/)[0]
    "#{download_folder.path}/#{pin.id}#{extension}"
  end

  def download_report(total_new_pins)
    puts "downloaded #{successes}/#{total_new_pins} images"
    puts "failed to download these images:" unless failures.empty?
    failures.each do |failure|
      puts "\t#{failure}"
    end

    puts "Images downloaded to: #{download_folder.path}"
  end

  def local_collection_size
    download_folder.count
  end
end
