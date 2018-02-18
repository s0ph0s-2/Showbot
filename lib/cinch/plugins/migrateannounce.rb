module Cinch
    module Plugins
        class MigrateAnnounce
            include Cinch::Plugin

            timer 1800, :method => :announce_migration
            match /vote\s.*/i, :method => :no_vote
            match /(sb|showbot)\s.*/i, :method => :no_showbot

            def announce_migration
                Channel("#furcast").send "Good news everyone! Anybody can suggest titles now! Just type \"!suggest <title>\" to put your ideas in the running. Also, title voting takes place online at https://furcast.fm/vote , throughout the whole show."
            end

            def no_vote(m)
                m.user.send("Voting happens online now! https://furcast.fm/vote")
            end

            def no_showbot(m)
                m.user.send("`!showbot' is now `!next' and `!news'. Give them a try!")
            end
        end
    end
end

