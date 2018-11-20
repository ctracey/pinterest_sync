require 'httparty'
require_relative 'pin_set'

class Board
  attr_accessor :id, :api_token, :page_count, :images, :most_recent_pin, :previous_synced_pin

  def initialize(id:, api_token:)
    @id = id
    @api_token = api_token
    @page_count = 0
    @images = []
  end

  def pins
    @images ||= load_pins
  end

  def load_pins
    page_url = most_recent_page_url

    puts "\trecently synced pin: #{@previous_synced_pin}" unless @previous_synced_pin.nil?
    puts 'reading board'
    while page_url do
      @page_count += 1

      pin_set = PinSet.new(page_url)
      puts "\t.[#{pin_set.pins.size}](#{pin_set.oldest_pin} - #{pin_set.newest_pin})"

      record_most_recent_pin(pin_id: pin_set.newest_pin)

      @images += pin_set.pins

      if pin_set.synced?(synced_pin_id: @previous_synced_pin)
        puts "\t.skipping synced pins"
        break
      end

      page_url = pin_set.next_set
    end
    puts "newest pin found: #{@most_recent_pin}\n"

    images
  end

  def most_recent_page_url
    "https://api.pinterest.com/v1/boards/#{id}/pins/?access_token=#{api_token}&limit=100&fields=id%2Cimage"
  end

  def record_most_recent_pin(pin_id:)
    @most_recent_pin = pin_id if @most_recent_pin.nil? || pin_id > @most_recent_pin
  end

  def image_count
    images.size
  end
end
