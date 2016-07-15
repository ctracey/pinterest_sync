require 'httparty'
require_relative 'pin_set'

class Board
  attr_accessor :id, :api_token

  def initialize(id:, api_token:)
    @id = id
    @api_token = api_token
  end

  def pins
    images = []
    page_url = "https://api.pinterest.com/v1/boards/#{id}/pins/?access_token=#{api_token}&limit=100&fields=id%2Cimage"

    pages = 0
    puts 'reading pages'
    while page_url do
      pages += 1
      print '.'
      pin_set = PinSet.new(page_url)
      images += pin_set.pins

      page_url = pin_set.next_set
    end
    puts "\n"

    puts "pages found: #{pages}"
    puts "images found: #{images.size}"

    images
  end

end
