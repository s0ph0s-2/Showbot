require 'cinch/cooldown'

module Cinch
  module Plugins
    class Help
      include Cinch::Plugin

      enforce_cooldown

      match /help$/i,       :method => :command_help          # !help
      match /help\s+(.+)/i, :method => :command_help_command  # !help <command>

      def help
        '!help - Uh, this.'
      end

      def help_help
        "#{help}\nUsage: !help [command]"
      end

      def command_help(m)
        bot.plugins.each do |plugin|
          m.user.send plugin.help if plugin.respond_to? :help
        end
      end

      def command_help_command(m, command)
        method_name = "help_#{command}".to_sym
        bot.plugins.each do |plugin|
          next if !plugin.respond_to? method_name
          help_text = plugin.send(method_name)
          m.user.send help_text.lines.first
          help_text.lines[1..-1].each do |line|
            m.user.send "  #{line}"
          end
        end
      end
    end
  end
end

