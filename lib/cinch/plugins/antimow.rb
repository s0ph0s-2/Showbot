module Cinch
  module Plugins
    class AntiMow
      include Cinch::Plugin

      match /\s*(mow ?)+\s*/i, use_prefix: false, :method => :command_counter
      match /Xana[,:]? shut up the sneps!?/i, use_prefix: false, :method => :command_block
      match /stop_sneps/i, :method => :command_block
      match /Xana[,:]? allow sneps\.?/i, use_prefix: false, :method => :command_allow
      match /allow_sneps/i, :method => :command_allow

      def initialize(*args)
        super
        @am_replying = false
        @allow_op_msgs = shared[:allow_op_msgs]
        @owner_nick = shared[:owner]
        @has_ns = shared[:server_has_nickserv]
        @dbg = true # Debugging
      end

      def command_counter(m)
        if @am_replying
          m.reply("wom")
        end
      end

      def command_block(m)
        unless authed? m.user
          m.user.send("Unfortunately, you can't tell me to do that.")
          return
        end
        m.user.send("I'm already doing that!") and return if @am_replying
        @am_replying = true
        m.action_reply("fist-pumps!")
      end

      def command_allow(m)
        unless authed? m.user
          m.user.send("Unfortunately, you can't tell me to do that.")
          return
        end
        m.user.send("I'm already doing that!") and return unless @am_replying
        @am_replying = false
        m.reply("Aww.")
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
