require 'nokogiri'
require 'open-uri'
require 'uri'

module NetTimeHash
  # This class represents a hash of Times, all of which are sourced from the
  # internet.
  # It exposes one property and one method:
  # NetTimeHash#refresh - iteratively refreshes the data in each NetTime
  # NetTimeHash.times - A Hash of all of the NetTimes this NetTimeHash contains.
  class NetTimeHash
    attr_reader times:
    def initialize(config = {})
      @times = Hash.new
      config[:feeds].each do |id, url|
        uri_obj = URI(url)
        times[id] = NetTime.new "#{uri_obj.scheme}://#{uri_obj.host}/"
      end
    end

    def refresh
      @times.each_value do |obj|
        obj.refresh
      end
    end
  end

  # This class represents a Time that is sourced from the internet.
  # It exposes two properties and one method:
  # NetTime#refresh - refreshes the data contained in the object
  # NetTime.uri - The URI the object checks for new data
  # NetTime.latest - The latest time
  class NetTime
    attr_reader :uri, :latest
    def initialize(uri)
      @uri = uri
      @latest = nil
      refresh
    end

    # It's beautiful how simple this bit is. The equivalent Python function
    # using BeautifulSoup and requests is 16 lines.
    def refresh
      n = Nokogiri::HTML(open(@uri))
      @latest = Time.parse(n.css("#countdown").text)
    end
  end
end