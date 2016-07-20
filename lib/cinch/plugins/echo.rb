module Cinch
  module Plugins
    class Echo
      include Cinch::Plugin

      match /say\s+(.*)\s(.*)/i, :method => :command_say # !say I am a bot
      match /do\s+(.*)\s(.*)/i, :method => :command_do # !do cuddles

      def help
        "!say — Echo back the arguments in a given channel or to a user."
        "!do — Echo back the arguments in a given channel or to a user, as an ACTION message."
      end

      def help_say
        "!say — Echo back the arguments in a given channel or to a user."
        "Usage: !say #example Hello!"
      end

      def help_do
        "!do — Echo back the arguments in a given channel or to a user, as an ACTION message."
        "Usage: !do #example wags."
      end

      def command_say(m, text)
        m.reply text
      end

      def command_do(m, action)
        m.action_reply action
    end
  end
end
