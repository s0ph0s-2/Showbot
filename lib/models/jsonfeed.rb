require 'json'
require 'date'
require 'open-uri'
require 'nokogiri'

# This module contains three related classes: Reader, Feed, and Item
module JSONFeed
    # JSONFeed::Reader is an object which contains Feeds, exposes one method,
    # and has one property
    # Reader#refresh - iteratively calls fetch_latest on its Feeds
    # Reader.feeds - a hash of the Feeds this Reader contains
    class Reader
        addr_reader :feeds
        def initialize(config = {})
            @feeds = Hash.new
            config[:feeds].each do |id, url|
                @feeds[id] = Feed.new(id, url)
            end
        end
    end

    def refresh
        @feeds.each_value do |feed|
            feed.fetch_latest
        end
    end

    # JSONFeed::Feed is an object which creates Items, exposes one method, and
    # has one property:
    # Feed#fetch_latest - fetch the latest item and save it
    # Feed.latest - the latest Item
    class Feed
        attr_reader :latest
        def initialize(id, url)
            @id = id
            @url = url
            @latest = null
            fetch_latest
        end

        def fetch_latest
            open(@url) do |jsondata|
                feed = JSON.parse(jsondata)
                latest = feed["items"][0]
                @latest = Item.new(
                    latest["title"],
                    DateTime.parse(latest["date_published"]),
                    latest["content_html"]
                )
            end
    end

    # A data storage object that stores three key pieces of information about an
    # item in a JSONFeed. It has the following read-only attributes:
    # title: the title of the feed item
    # date: the date the feed item was posted
    # body: the body of the feed item
    # The RSSItem converts HTML bodies to text for easy usage in non-XML
    # contexts.
    class Item
        attr_reader :title, :date, :body

        def initialize(title, date, body)
            @title =title
            @date = date
            @body = Nokogiri::HTML(body).text
        end
    end
end
