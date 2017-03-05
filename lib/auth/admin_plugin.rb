module Auth
  module AdminPlugin
    UNREGISTERED_MSG = "You must be registered to execute admin commands!"
    UNAUTHORIZED_MSG = "You are not authorized to execute that command! I will now self destruct."

    def self.init(admins=[])
      @@admins = admins
    end

    module ClassMethods
      def admin_match(pattern, options={})
        _options = { :method => :execute }.merge(options)
        user_method = _options[:method]
        admin_method = AdminPlugin.mangled_method_name(_options)

        self.send(:define_method, admin_method) do |*args| # self == Plugin::Class
          message = args[0]

#           if !message.user.authed?
#             message.user.send AdminPlugin::UNREGISTERED_MSG
          if AdminPlugin.is_admin? message.user
            self.send(user_method, *args) # self == Plugin::Class instance
          else
            unauthorized_msg = if options.key?(:unauthorized_msg) then
              options[:unauthorized_msg]
            else
              AdminPlugin::UNAUTHORIZED_MSG
            end

            message.user.send unauthorized_msg
          end
        end

        options[:method] = admin_method

        match pattern, options
      end
    end

    def self.included klass
      # Expose class level API for metaconfig
      klass.extend ClassMethods

      ############################################################
      # AdminPlugin should include Cinch::Plugin alongside itself when included
      # Cinch::Plugin cannot be included in AdminPlugin because Cinch::Plugin::ClassMethods
      # (match, for example) would be applied to AdminPlugin instead of the target class
      # Manual inclusion ensures these ClassMethods will apply to the correct target
      klass.class_eval do
        include Cinch::Plugin
      end
      ############################################################
    end

    private

    def self.mangled_method_name(options)
      "__auth_admin_#{options[:method]}".to_sym
    end

    def self.is_admin?(user)
      @@admins.include? user.nick
    end
  end
end
