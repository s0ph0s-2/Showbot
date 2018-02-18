require 'open-uri'
require 'nokogiri'

module Cinch
    module Plugins
        class TracklistReplace
            include Cinch::Plugin

            timer 5, :method => :scrape_track

            match /Xana, the tracklist bot is down[!\.]?/i, use_prefix: false, :method => :bot_down
            match /Xana, the tracklist bot is (back)? up\.?/i, use_prefix: false, :method => :bot_up

            def initialize(*args)
                super
                @track_net = false
                @latest_track = "Not Scraped Yet"
                @owner_nick = shared[:owner]
                @has_ns = shared[:server_has_nickserv]
                @allow_op_msgs = shared[:allow_op_msgs]
                @scrape_url = config["scrape_url"]
            end

            def bot_down(m)
                m.user.send "Sorry, but you have to be an admin to do that." unless authed? m.user 
                @track_net = true
                m.reply "I'm on it!"
                scrape_track
            end

            def bot_up(m)
                m.user.send "Sorry, but you have to be an admin to do that." unless authed? m.user

                @track_net = false
                m.reply "Glad I could help!"
            end

            def scrape_track
                return unless @track_net
                n = Nokogiri::XML(open(@scrape_url))
                new_track = n.css("song")[0].text
                if new_track != @latest_track
                    @latest_track = new_track
                    Channel("#FNT").send "Now Playing on XBN: " + new_track
                end
            end
            
            def authed?(user)
                if @allow_op_msgs
                    (user.nick == @owner_nick || user.oper?) && (user.authed? || !@has_ns) 
                else
                    user.nick == @owner_nick && (user.authed? || !@has_ns)
                end
           end
        end
    end
end

