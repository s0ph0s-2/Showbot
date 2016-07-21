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
      end

      def counter_mow(m)
        if @am_replying
          m.reply("wom")
        end
      end

      def block_mow(m)
      end

      def allow_mow(m)
      end

    end
  end
end
