require 'chronic_duration'
require 'cinch/cooldown'

module Cinch
  module Plugins
    class Uptime
      include Cinch::Plugin

      enforce_cooldown

      match /uptime/i,  :method => :command_uptime  # !uptime

      def help
        "!uptime - How long has #{shared[:Bot_Nick]} been continuously running?"
      end

      def help_uptime
        "#{help}\nUsage: !uptime"
      end

      def initialize(*args)
        super
        @start_time = Time.now
      end

      def command_uptime(m)
        m.user.send "#{shared[:Bot_Nick]} has been running for #{fancy_running}, " +
          "since #{date_string} at #{time_string}"
      end

      private

      def date_string
        @start_time.strftime('%-m/%-d/%Y')
      end

      def time_string
        @start_time.strftime('%-I:%M%P')
      end

      def fancy_running
        ChronicDuration.output(seconds_running, :format => :long)
      end

      def seconds_running
        (Time.now - @start_time).to_i
      end
    end
  end
end

