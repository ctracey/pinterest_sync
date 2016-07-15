require 'digest'

class Downloader

  attr_accessor :pins, :successes, :failures, :download_folder

  def initialize(pins:, download_folder:)
    @pins = pins
    @download_folder = download_folder

    @failures = []
    @successes = 0
  end

  def run
    begin
      Dir.mkdir(download_folder) unless Dir.exists?(download_folder)
      puts "#{total_pins} images to download"
      pins.each_with_index do |pin, i|
        filename = filename(pin, i)
        if image_exists?(filename)
          puts image_progress(pin.url, i, skipped: true)
          @successes += 1
        else
          img_response = get_image(pin.url, i)

          if img_response.code == 200
            save_image(img_response, filename)
            @successes += 1
          else
            @failures << pin.url
          end
        end
      end
    rescue StandardError => e
      puts "Error: #{e.message}"
      puts e.backtrace
    end

    download_report
  end

  private

  def total_pins
    pins.size
  end

  def get_image(url, file_number)
    print image_progress(url, file_number)
    response = HTTParty.get(url)
    puts response.code
    response
  end

  def image_progress(url, file_number, skipped: false)
    image = "\t#{file_number}/#{total_pins}"
    if skipped
      progress = "skipped"
    else
      progress = "downloading #{url} ... "
    end

    "#{image} #{progress}"
  end

  def save_image(response, filename)
    img = File.new(filename, 'w')
    img.write(response.body)
    img.close
  end

  def image_exists?(filename)
    File.exists?(filename)
  end

  def filename(pin, file_number)
    extension = pin.url.match(/\.[a-z]*$/)[0]
    "#{download_folder}/#{pin.id}#{extension}"
  end

  def download_report
    puts "downloaded #{@successes}/#{total_pins} images"
    puts "failed to download these images:" unless @failures.empty?
    @failures.each do |failure|
      puts "\t#{failure}"
    end

    puts "Images downloaded to: #{download_folder}"
  end
end
