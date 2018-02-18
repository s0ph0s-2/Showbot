# links.rb
#
# Cinch plugin to gather links from IRC and put them in a database
#
# Gotta link 'em all

require 'cinch/cooldown'
require 'addressable/uri'

module Cinch
  module Plugins
    class Links
      include Cinch::Plugin

      enforce_cooldown

      match /link\s+(.*)/i,     :method => :command_link      # !link http://example.com/greatest-link-ever

      def help
        '!link - Know the link for that? Suggest it and make the show better.'
      end

      def help_link
        [
          help,
          'Usage: !link http://example.com/greatest-link-ever',
          "Go to #{shared[:Sinatra_Url]}links to see the link suggestions."
        ].join "\n"
      end

      # Add the user's link to the database
      def command_link(m, uri_string)
        if uri_string.empty?
          m.user.send help_link
        else
          # Verify this is a valid URI
          uri = Addressable::URI::parse(uri_string)

          if uri.scheme.nil?
            # No scheme for URI, parse it again with http in front
            uri = Addressable::URI.parse("http://#{uri.to_s}")
          end

          new_link = Link.create(
            :uri  => uri,
            :user => m.user.nick
          )

          if new_link.saved?
            m.user.send "Added link suggestion #{new_link.uri}"
          else
            new_link.errors.each do |e|
              m.user.send e.first
            end
          end
        end
      end
    end
  end
end

