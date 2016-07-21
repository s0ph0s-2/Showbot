module Cinchize
  module Plugin
    class AntiMow
      include Cinch::Plugin

      match /^\s+(mow ?)+\s+$/i, :use_prefix => false, :method => :counter_mow
      match /#{shared[:Bot_Nick]}[,:]? shut up the sneps!?/, :use_prefix => false, :method => :block_mow
      match /stop_sneps/, :method => :block_mow
      match /#{shared[:Bot_Nick]}[,:]? allow sneps\.?/, :use_prefix => false, :method => :allow_mow
      match /allow_sneps/, :method => :allow_mow

      def initialize(*args)
        @am_replying = false
        @allow_op_msgs = shared[:allow_op_msgs]
        @owner = shared[:owner]
        @has_ns = shared[:server_has_nickserv]
      end

      def counter_mow(m)
        if @am_replying
          m.reply("wom")
        end
      end

      def block_mow(m)
        unless authed? m.user
          m.user.send("Unfortunately, you can't tell me to do that.")
          return
        end
        @am_replying = true
        m.action_reply("fist-pumps!")
      end

      def allow_mow(m)
        unless authed? m.user
          m.user.send("Unfortunately, you can't tell me to do that.")
          return
        end
        @am_replying = false
        m.reply("Aww.")
      end

      def authed?(u)
        if @allow_op_msgs
          (user.nick == @owner_nick || user.oper?) && (user.authed? || !@has_ns)
        else
          user.nick == @owner_nick && (user.authed? || !@has_ns)
        end
      end
    end
  end
end
