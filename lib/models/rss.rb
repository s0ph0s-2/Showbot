require 'rss'
require 'open-uri'
require 'nokogiri'

# This module contains three related classes: RSSReader, RSSFeed, and RSSItem.
module RSS
  # RSSReader is an object which contains RSSFeeds and exposes one method:
  # RSSReader#latest(show)
  # This method fetches the latest item from the feed specified in show and
  # returns it as an RSSItem
  class RSSReader
    def initialize(config = {})
      @feeds = Hash.new()
      config[:feeds].each do |id, url|
        @feeds[id] = RSSFeed.new(id, url)
      end
    end

    def latest(show)
      @feeds[show].fetch_latest
    end
  end

  # RSSFeed is an object which creates RSSItems and exposes one method:
  # RSSFeed#fetch_latest
  # This method fetches the latest item from the feed and returns it as an
  # RSSItem
  class RSSFeed
    def initialize(id, url)
      @id = id
      @url = url
    end

    def fetch_latest
      open(@url) do |rss|
        feed = RSS::Parser.parse(rss)
        latest = feed.items.first
        # Surprisingly, latest.pubDate is already a Time.
        RSSItem.new(latest.title, latest.pubDate, latest.content_encoded)
      end
    end
  end

  # A data storage object that stores three key pieces of information about an
  # item in an RSS feed. It has the following read-only attributes
  # title: the title of the feed item
  # date: the date the feed item was posted
  # body: the body of the feed item
  # The RSSItem converts HTML titles and bodies to text for easy usage in
  # non-XML contexts.
  class RSSItem
    attr_reader :title, :date, :body

    def initialize(title, date, body)
      @title = Nokogiri::HTML(title).text
      @date = date
      @body = Nokogiri::HTML(body).text
    end
  end
end
