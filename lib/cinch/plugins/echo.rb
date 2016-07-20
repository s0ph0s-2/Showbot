module Cinch
  module Plugins
    class Echo
      include Cinch::Plugin

      match /say\s+(.*)/i, :method => :command_say # !say I am a bot
      match /do\s+(.*)/i, :method => :command_do # !do cuddles

      def command_say(m, text)
        m.reply text
      end

      def command_do(m, action)
        m.action_reply action
    end
  end
end
