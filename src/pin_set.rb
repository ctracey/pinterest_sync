require_relative 'pin'

class PinSet
  attr_accessor :page_url

  def initialize(page_url)
    @page_url = page_url
  end

  def pins
    pins_data.map do |pin|
      id = pin['id']
      url = pin['image']['original']['url']
      Pin.new(id: id, url: url)
    end
  end

  def next_set
    set_page['page']['next']
  end

  private

  def pins_data
    set_page['data']
  end

  def set_page
    @set_page ||= load_set_page
  end

  def load_set_page
    pins_json = HTTParty.get(page_url).body
    set_page = JSON.parse(pins_json)
    if set_page['data'].nil?
      raise "SYNC ERROR: #{set_page['message']}"
    end
    set_page
  end
end
