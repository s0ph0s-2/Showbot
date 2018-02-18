require 'nokogiri'
require 'open-uri'
require 'uri'

module NetTimeHash
  # This class represents a hash of Times, all of which are sourced from the
  # internet.
  # It exposes one property and one method:
  # NetTimeHash#latest(show) - Calls latest on the NetTime referenced by show
  # NetTimeHash.times - A Hash of all of the NetTimes this NetTimeHash contains.
  class NetTimeHash
    attr_reader :times
    def initialize(config = {})
      @times = Hash.new
      config[:feeds].each do |id, url|
        uri_obj = URI(url)
        times[id] = NetTime.new "#{uri_obj.scheme}://#{uri_obj.host}/"
      end
    end

    def latest(show)
      @times[show].latest
    end
  end

  # This class represents a Time that is sourced from the internet.
  # It exposes one property and one method:
  # NetTime#latest - fetchest the latest data from online
  # NetTime.uri - The URI the object checks for new data
  class NetTime
    attr_reader :uri
    def initialize(uri)
      @uri = uri
    end

    # It's beautiful how simple this bit is. The equivalent Python function
    # using BeautifulSoup and requests is 16 lines.
    def latest
      n = Nokogiri::HTML(open(@uri))
      Time.at(n.css(".countdown-clock").attribute("data-date").value.to_i/1000)
    end
  end
end
