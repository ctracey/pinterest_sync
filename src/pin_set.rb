require_relative 'pin'

class PinSet
  attr_accessor :page_url

  def initialize(page_url)
    @page_url = page_url
    @pin_ids = []
  end

  def pins
    @pins ||= load_pins
  end

  def next_set
    @next_set ||= set_page['page']['next']
  end

  def synced?(synced_pin_id:)
    return false if synced_pin_id.nil?
    oldest_pin <= synced_pin_id
  end

  def oldest_pin
    pin_ids.min
  end

  def newest_pin
    pin_ids.max
  end

  private

  def pins_data
    @pins_data ||= set_page['data']
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

  def load_pins
    pins_data.map do |pin|
      id = pin['id']
      @pin_ids << id
      url = pin['image']['original']['url']
      Pin.new(id: id, url: url)
    end
  end

  def pin_ids
    load_pins if @pin_ids.nil?
    @pin_ids
  end
end
