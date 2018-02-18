require 'nokogiri'
require 'eat'
require 'openssl'
require 'cinch/cooldown'

module Cinch
  module Plugins
    class LinkTitle
      include Cinch::Plugin

      enforce_cooldown

      match /(https?\:\/\/.*?)(\s|$)/, use_prefix: false

      # Default list of URL regexps to ignore.
      DEFAULT_BLACKLIST = [
        /\.png$/i,  /\.jpe?g$/i,  /\.bmp$/i,  /\.gif$/i,  /\.pdf$/i,  /\.doc$/i,
        /\.ppt$/i,  /\.odt$/i,    /\.xls$/i,  /\.zip$/i,  /\.mp3$/i,  /\.m4a$/i,
        /\.ogg$/i,  /\.wav$/i,    /\.mp4$/i,  /\.m4v$/i,  /\.mov$/i,  /\.wmv$/i,
        /\.avi$/i,  /\.mpe?g$/i,  /\.ogv$/i,  /\.3gp$/i,  /\.3g2$/i
      ].freeze

      def initialize(*args)
        super
        @blacklist = DEFAULT_BLACKLIST.dup
        @blacklist.concat(config[:blacklist]) if config[:blacklist]
        @blacklist.freeze
      end

      def execute(m, url)
        return if blacklisted? url

        site = fetch_html url
        title = extract_title site

        if title.empty?
          m.reply '^ No title or could not fetch title.'
        else
          m.reply '^ ' + truncate_title(title)
        end
      end

      private

      def blacklisted?(url)
        @blacklist.any? do |entry|
          url =~ entry
        end
      end

      def fetch_html(url)
        Nokogiri::HTML(eat(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
      end

      def extract_title(html)
        html.css('title').first.text.gsub(/\s+/, ' ').strip
      end

      def truncate_title(title)
        return title if title.length <= 200

        title[0..200] + '... [Truncated]'
      end
    end
  end
end
