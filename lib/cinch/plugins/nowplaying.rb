module Cinch
  module Plugins
    class NowPlaying
      include Cinch::Plugin
      # command #channel The Artist [HYPHEN-MINUS,EN DASH,EM DASH] Some Track
      match /(np)\s+([#&][^\x07\x2C\s]{,200})\s+(.*)\s[-–—]\s(.*)/i, :method => :command_np

      def initialize(*args)
        super
        @owner_nick = shared[:owner]
        @allow_op_msgs = shared[:allow_op_msgs]
        @has_ns = shared[:server_has_nickserv]
      end

      def help
        "!np - Tell the channel what track is currently playing."
      end

      def help_np
        [
          help,
          "Usage: !np #channel [--181] Some Artist - A Track"
        ].join("\n")
      end

      def command_np(m, cmd, chan, artist, track)
        m.user.send("Only admins can ask me to do that.") and return unless authed? m.user
        m.user.send("You have to send me a PM to use this command.") and return if m.channel?

        artist_split = artist.split(" ")
        if artist_split.first == "--181"
          artist = artist_split[1..-1].join(" ")
          Channel(chan).send("Now Playing on XBN: The Eagle at 181.FM (#{artist} — #{track})")
        else
          Channel(chan).send("Now Playing on XBN: #{artist} — #{track}")
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
