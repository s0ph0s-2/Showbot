require 'cinch/cooldown'

module Cinch
  module Plugins
    class About
      include Cinch::Plugin

      enforce_cooldown

      match /about/i, :method => :command_about # !about

      def help
        "!about - Was #{shared[:Bot_Nick]} coded or did it spontaniously come into existence?"
      end

      def help_about
        "#{help}\nUsage: !about"
      end

      # Show information about JBot
      def command_about(m)
        m.user.send "JBot was created by Jeremy Mack (@mutewinter) and some awesome contributors on github." +
          "The project page is located at https://github.com/rikai/Showbot"
        m.user.send "Type !help for a list of JBot's commands"
      end
    end
  end
end

