require 'rss'
require 'open-uri'

module RSSReader
  class RSSFeed
  end

  # A data storage object that stores three key pieces of information about an
  # item in an RSS feed. It has the following read-only attributes
  # title: the title of the feed item
  # date: the date the feed item was posted
  # body: the body of the feed item
  class RSSItem
    attr_reader title, date, body

    def initialize(title, date, body)
      @title = title
      @date = date
      @body = body
    end
  end
end
