class AdminList
    @@initialized = false
    @@admins = []
    def self.initialize(options)
        @@admins = options[:admins]
        @@initialized = true
    end

    def self.include?(nick)
        @admins.include? nick
    end

    def self.authed?(user_obj)
        @admins.include user_obj.nick and user_obj.authed?
    end
end

