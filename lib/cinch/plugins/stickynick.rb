require 'cinch/cooldown'

module Cinch
  module Plugins
    class StickyNick
      include Cinch::Plugin

      enforce_cooldown

      timer 300, :method => :fix_nick

      # Called every 5 minutes to attempt to fix the bots name.
      # This can happen if the bot gets disconnected and reconnects before
      # the last bot as been kicked from the IRC server.
      def fix_nick
        if bot.nick != preferred_nick
          bot.info "Nick is #{bot.nick}, but should be #{preferred_nick}. Fixing nickname."
          bot.nick = preferred_nick
        end
      end

      private

      def preferred_nick
        shared[:Bot_Nick]
      end
    end
  end
end

