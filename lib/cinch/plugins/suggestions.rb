# All suggestions welcome.

module Cinch
  module Plugins
    class Suggestions
      include Cinch::Plugin
      require 'net/http'
      require 'uri'

      match /suggest\s+(.*)/i,  :method => :command_suggest       # !suggest Great Title Here

      # Show help for the suggestions module
      def help
        '!suggest - Be heard. Suggest a title for the live show.'
      end

      def help_suggest
        [
          help,
          'Usage: !suggest Sweet Show Title'
        ].join "\n"
      end

      # Add the user's suggestion to the database
      def command_suggest(m, title)
        if title.empty?
          m.user.send help_suggest
        else
          new_suggestion = Suggestion.create(
            :title      => title,
            :user       => m.user.nick
          )

          if new_suggestion.saved?
            m.user.send "Added title suggestion \"#{new_suggestion.title}\""

            # Notify web server of new suggestion if enabled
            if config.has_key?('live_titles') and config['live_titles']['enabled']
              hosts_key = ARGV[0] == 'network_test' ? 'test_hosts' : 'live_hosts'
              sinatra_root = config['live_titles'][hosts_key]['Sinatra_Url']
              new_title_trigger_uri =
                URI.parse("#{sinatra_root}/new_title_trigger?id=#{new_suggestion.id}")
              Net::HTTP.get_response(new_title_trigger_uri)
            end
          else
            new_suggestion.errors.each do |e|
              m.user.send e.first
            end
          end
        end
      end
    end
  end
end

