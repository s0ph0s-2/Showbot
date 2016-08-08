module Cinch
  module Plugins
    class DigitalOcean
      include Auth::AdminPlugin

      DO_UNAUTHORIZED_MSG = 'You are not authorized for droplet access.'

      [{
        :pattern => /droplet\slist$/i,
        :method => :command_droplet_list,
      }, {
        :pattern => /droplet\sstart\s(.+)/i,
        :method => :command_droplet_start,
      }, {
        :pattern => /droplet\sstop\s(.+)/i,
        :method => :command_droplet_stop,
      }, {
        :pattern => /droplet\sshutdown\s(.+)/i,
        :method => :command_droplet_shutdown,
      }].each do |m|
        admin_match m[:pattern], {
          :method => m[:method],
          :unauthorized_msg => DigitalOcean::DO_UNAUTHORIZED_MSG
        }
      end

      def initialize(*args)
        super *args
        @do_client = DropletKit::Client.new(access_token: ENV['DO_API_KEY']) if ENV['DO_API_KEY']
      end

      def find_droplet_by_name(name)
        @do_client.droplets.all.find { |droplet| droplet.name == name }
      end

      def command_droplet_list(m)
        m.user.send '=============================='
        m.user.send 'Listing known droplets...'
        m.user.send '=============================='

        @do_client.droplets.all.each do |droplet|
          m.user.send "[#{droplet[:name]}]"
          m.user.send "  status: #{droplet[:status]}"
        end

        m.user.send '=============================='
        m.user.send 'Droplet list complete.'
        m.user.send '=============================='
      end

      def command_droplet_start(m, name)
        begin
          @do_client.droplet_actions.power_on(droplet_id: find_droplet_by_name(name).id)
          m.user.send "Request to start droplet #{name} succeeded!"
        rescue
          m.user.send 'An error occurred requesting the droplet to start. Is your ID correct?'
        end
      end

      def command_droplet_stop(m, name)
        begin
          @do_client.droplet_actions.power_off(droplet_id: find_droplet_by_name(name).id)
          m.user.send "Request to stop droplet #{name} succeeded!"
        rescue
          m.user.send 'An error occurred requesting the droplet to stop. Is your ID correct?'
        end
      end

      def command_droplet_shutdown(m, name)
        begin
          @do_client.droplet_actions.shutdown(droplet_id: find_droplet_by_name(name).id)
          m.user.send "Request to stop droplet #{name} succeeded!"
        rescue
          m.user.send 'An error occurred requesting the droplet to stop. Is your ID correct?'
        end
      end
    end
  end
end
