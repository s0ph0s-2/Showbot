require 'optparse'
require 'tzinfo'

require './lib/models/shows'
require './lib/models/calendar'

module Cinch
  module Plugins
    class Schedule
      include Cinch::Plugin

      timer 600, :method => :refresh_calendar

      listen_to :connect, :method => :on_connect

      match /next\s*$/i,    :method => :command_next      # !next
      match /next\s+(.+)/i, :method => :command_next      # !next <show>
      match /news\s+([a-z]+)/i, :method => :command_news  # !news <show>

      def help
        [
          '!next - When\'s the next live show?',
          '!news - What\'s the latest news for a given show?'
        ].join "\n"
      end

      def help_next
        [
          '!next - When\'s the next live show?',
          'Usage: !next [show]'
        ].join "\n"
      end

      def help_news
        [
          '!news - What\'s the latest news for a given show?',
          'Usage: !news [show]'
        ].join "\n"
      end

      def initialize(*args)
        super
        @calendar = Calendar.new(config)
        @events = []
      end

      # A method called on connection to an IRC server
      # Use to call any additional initialization
      def on_connect(m)
        refresh_calendar
      end

      # Pulls in the latest calendar events and stores them in @events
      # Called by a timer to keep up to date with the calendar
      def refresh_calendar
        @events = @calendar.events
      end

      def command_next(m, opts = '')
        parsed_options = {
          :tz => get_timezone_from_name('UTC')
        }

        begin
          opts = opts.split /\s+/
          opt_parser = OptionParser.new do |parser|
            parser.on('-z', '--tz ZONE', 'ZONE required.') do |zone|
              parsed_options[:tz] = get_timezone_from_name(zone)
            end
          end
          opt_parser.parse!(opts)

          named_show = opts.join(' ').strip
          if named_show.empty?
            next_show(m, parsed_options)
          else
            next_named_show(m, named_show, parsed_options)
          end
        rescue OptionParser::InvalidOption => ioe
          m.user.send ioe.message
        rescue OptionParser::MissingArgument => mae
          m.user.send mae.message
        rescue TZInfo::InvalidTimezoneIdentifier
          m.user.send 'That is not a valid timezone. For a list of valid time zones, please see http://en.wikipedia.org/wiki/List_of_tz_database_time_zones'
        end
      end

      # Get the news for a show
      def command_news(m, show)
      end

      # Replies to the user with information about the next show
      # !next -> Next show is Linux Action Show in 3 hours 30 minutes (6/2/2011)
      def next_show(m, opts)
        response = ""

        event = live_event

        if event
          response << "#{event.summary} is live right now! "
        end

        event = next_event

        if event
          response << "Next show is #{event.summary}"
          response << " in #{in_how_long(event, opts[:tz])}"
        else
          response << "No upcoming show found in the next week"
        end

        m.reply response
      end

      # Replies to the user with information about the next specified show
      # !next cr -> The next Coder Radio is in 3 hours 30 minutes (6/2/2011)
      def next_named_show(m, show_keyword, opts)
        if show_keyword.strip.empty?
          command_next(m)
          return
        end

        show = Shows.find_show(show_keyword)

        if !show
          if show_keyword.strip == "Robert'); DROP TABLE students;--"
            m.reply "Oh, yes. Little Bobby Tables, we call him."
          else
            m.reply "Cannot find a show for #{show_keyword}"
          end

          return
        end

        event = next_event(show)

        if !event
          m.reply "No upcoming show found for #{show.title} in the next week"
          return
        end

        response = ""

        response << "The next #{event.summary} is"
        response << " in #{in_how_long(event, opts[:tz])}"

        m.reply response
      end

      protected

      def get_timezone_from_name(tz_name)
        comparable_tz_name = tz_name.downcase

        canonical_tz_name = TZInfo::Timezone.all_identifiers.select do |tz_identifier|
          tz_identifier.downcase == comparable_tz_name
        end.first

        TZInfo::Timezone.get(canonical_tz_name)
      end

      def in_how_long(event, tz)
        "#{event.fancy_time_until} (#{event.start_time_to_local_string(tz)} on #{event.start_date_to_local_string(tz)})"
      end

      # Get a live event if there is one, or nil
      def live_event
        @events.select do |event|
          event.covers? Time.now
        end.first
      end

      # Gets the next event from the list of events
      # If a show is provided, search the events for a summary that starts with
      # show.title, and return the next event of that show
      def next_event(show = nil)
        if show.nil?
          @events
        else
          @events.select do |event|
            event.summary.start_with? show.title
          end
        end.select do |event|
          event.after? Time.now
        end.first
      end
    end
  end
end

