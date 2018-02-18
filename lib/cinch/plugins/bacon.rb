require 'cinch/cooldown'

module Cinch
  module Plugins
    class Bacon
      include Cinch::Plugin

      enforce_cooldown

      match /bacon$/i,        :method => :command_bacon       # !bacon
      match /bacon\s+(\S+)/i, :method => :command_bacon_gift  # !bacon <user>

      def help
        '!bacon - Delicious bacon.'
      end

      def help_bacon
        [
          help,
          'Usage: !bacon [user]'
        ].join "\n"
      end

      def command_bacon(m)
        return if !m.channel?

        m.action_reply "gives #{m.user} a strip of delicious bacon."
      end

      def command_bacon_gift(m, user_name)
        with_channel_user(m, user_name) do |to_user|
          m.action_reply "gives #{to_user} a strip of delicious bacon as a gift from #{m.user}."
        end
      end

      private

      def with_channel_user(m, user)
        return unless m.channel?

        target_user = m.channel.users.keys.select do |channel_user|
          channel_user.to_s.casecmp(user).zero?
        end.first

        return if target_user.nil?

        yield target_user
      end
    end
  end
end
