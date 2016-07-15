class Pin
  attr_accessor :id, :url

  def initialize(id:, url:)
    @id = id
    @url = url
  end

  def to_s
    url
  end
end
