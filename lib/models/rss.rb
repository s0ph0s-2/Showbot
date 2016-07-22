require 'rss'
require 'open-uri'
require 'nokogiri'

# This module contains three related classes: RSSReader, RSSFeed, and RSSItem.
module RSS
  # RSSReader is an object which contains RSSFeeds, exposes one method, and
  # has one property
  # RSSReader#refresh - iteratively calls fetch_latest on its RSSFeeds
  # RSSReader.feeds - a hash of the RSSFeeds this Reader contains
  class RSSReader
    attr_reader :feeds
    def initialize(config = {})
      @feeds = Hash.new
      config[:feeds].each do |id, url|
        @feeds[id] = RSSFeed.new(id, url)
      end
    end

    def refresh
      @feeds.each_value do |feed|
        feed.fetch_latest
      end
    end
  end

  # RSSFeed is an object which creates RSSItems, exposes one method, and has
  # one property:
  # RSSFeed#fetch_latest - Fetch the latest item and save it
  # RSSFeed.latest - The latest RSSItem
  class RSSFeed
    attr_reader :latest
    def initialize(id, url)
      @id = id
      @url = url
      @latest = nil
      fetch_latest
    end

    def fetch_latest
      open(@url) do |rss|
        feed = RSS::Parser.parse(rss)
        latest = feed.items.first
        # Surprisingly, latest.pubDate is already a Time.
        @latest = RSSItem.new(latest.title, latest.pubDate, latest.content_encoded)
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
