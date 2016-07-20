module Cinch
  module Plugins
    class Echo
      include Cinch::Plugin

      # Per RFC 2812, nicks are [A-z_\-\[\]\\^{}|`][A-z0-9_\-\[\]\\^{}|`]{0,8}
      #               chans are [#&][^\x07\x2C\s]{,200}
      # My particular server is configured to permit nicks up to 40 chars.
      match /say\s+([A-z_\-\[\]\\^{}|`][A-z0-9_\-\[\]\\^{}|`]{1,39}|[#&][^\x07\x2C\s]{,200})\s+(.*)/i, :method => :command_say # !say #channel I am a bot
      match /do\s+([A-z_\-\[\]\\^{}|`][A-z0-9_\-\[\]\\^{}|`]{1,39}|[#&][^\x07\x2C\s]{,200})\s+(.*)/i, :method => :command_do # !do ExampleUser cuddles

      def initialize(*args)
        super
        @owner_nick = config[:owner]
        @allow_op_msgs = config[:allow_op_msgs]
        @has_ns = config[:server_has_nickserv]
      end

      def help
        [
          "!say — Echo back the arguments in a given channel or to a user.",
          "!do — Echo back the arguments in a given channel or to a user, as an ACTION message."
        ].join("\n")
      end

      def help_say
        [
          "!say — Echo back the arguments in a given channel or to a user.",
          "Usage: !say #example Hello!"
        ].join("\n")
      end

      def help_do
        [
          "!do — Echo back the arguments in a given channel or to a user, as an ACTION message.",
          "Usage: !do #example wags."
        ].join("\n")
      end

      def command_say(m, dest, msg)
        unless authed? m.user
          m.user.send("Unfortunately, you're not allowed to make me talk.")
          return
        end
        if dest[1] == "#"
          Channel(dest).send(msg)
        else
          User(dest).send(msg)
        end
      end

      def command_do(m, dest, action)
        unless authed? m.user
          m.user.send("Unfortunately, you're not allowed to make me do stuff.")
          return
        end
        if dest[1] == "#"
          Channel(dest).action(action)
        else
          User(dest).action(action)
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
