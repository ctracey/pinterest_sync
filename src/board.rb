require 'httparty'
require_relative 'pin_set'

class Board
  attr_accessor :id, :api_token, :page_count, :images

  def initialize(id:, api_token:)
    @id = id
    @api_token = api_token
    @page_count = 0
    @images = []
  end

  def pins
    page_url = "https://api.pinterest.com/v1/boards/#{id}/pins/?access_token=#{api_token}&limit=100&fields=id%2Cimage"

    puts 'reading board'
    while page_url do
      print '.'
      @page_count += 1

      pin_set = PinSet.new(page_url)
      @images += pin_set.pins
      page_url = pin_set.next_set
    end
    puts "\n"

    images
  end

  def image_count
    images.size
  end
end
