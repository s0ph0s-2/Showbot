require 'time'
require 'json'

module Cinch
  module Plugins
    class ChapterTag
      include Cinch::Plugin


      match(/(chaptertag|ct)\s+([a-z]+)\s*(.*)/i, :method => :command_chaptertag)
      match(/Now Playing (?:\(Bit Perfectly\) )?on XBN: (.+)/, use_prefix: false, :method => :command_record)

      def initialize(*args)
        super
        @watch_channel = config[:watch_channel]
        @watch_nick = config[:watch_nick]
        @is_recording = false
        @time_stack = []
        @intro_length = 105670
        @start_time = nil
        @json_dir = config[:json_dir]
        @owner_nick = shared[:owner]
        @allow_op_msgs = shared[:allow_op_msgs]
        @has_ns = shared[:server_has_nickserv]
      end

      def help
        ""
      end

      def help_chaptertag
        ""
      end

      def help_ct
        help_chaptertag
      end

      def command_chaptertag(m, command, verb, args)
        m.user.send("You need to be an admin to use that command.") and return unless authed? m.user
        m.user.send("You need to send me that command in a PM.") and return if m.channel?

        case verb
        when "start"
          @is_recording = true
          m.user.send("I'll start recording when #{@watch_nick} announces the first track.")
        when "stop"
          @is_recording = false
          ret_val = save_data(nil)
          if ret_val.is_a? String
            m.user.send(ret_val)
          else
            m.user.send("I've stopped recording and saved the file to #{@json_dir}.")
          end
        when "reset"
          @is_recording = false
          ret_val = save_data("#{@json_dir}/backups/#{@start_time.strftime("%0F")}.json")
          if ret_val.is_a? String
            m.user.send(ret_val)
          else
            @start_time = nil
            @time_stack = []
            m.user.send("Everything's reset!")
          end
        when "save"
          unless args == ""
            save_data(args)
            m.user.send("I've saved the file to #{args}.")
          else
            save_data(nil)
            m.user.send("I've saved the file to #{@json_dir}/#{@start_time.strftime("%0F")}.json.")
          end
        when "last"
          if @is_recording
            m.user.send("The last track I got was \"#{@time_stack[-1][0]}\".")
          else
            m.user.send("I'm not recording; I don't have a last track to give you.")
          end
        else
          m.user.send("I don't know what that subcommand means.")
        end
      end

      def command_record(m, artist_track)
        return unless @is_recording
        return unless m.channel == @watch_channel
        return unless m.user.nick == @watch_nick

        # How much should I shift the tracks forward by?
        # This saves the time recording when it isn't started before the intro.
        intro_offset_correction = 0
        # If there are no times yet,
        if @time_stack.empty?
          # Record the start time as now.
          @start_time = Time.now
          # Unless the name of the first track starts with "fnt-"
          unless artist_track[0..3] == "fnt-"
            # Offset the tracks by the intro length
            intro_offset_correction = @intro_length
            # And stick the intro in
            @time_stack << ["fnt-s7-intro-draft6", 0.0]
          end
        end
        # Append an array containing
        @time_stack << [
          # The artist and track title
          artist_track,
          # and the difference between the start and now, in ms
          ((Time.now - @start_time) * 1000) + intro_offset_correction
        ]
        # Notice the owner that a track has been recorded.
        User(@owner_nick).notice("Recorded \"#{artist_track}\".")
      end

      private

      def save_data(path)
        # Save a timestamp in ISO format to use as the filename. Probably unique.
        date_id = @start_time.strftime("%0F")
        # If path is nil, set it to the default location.
        if path.nil?
          path = "#{@json_dir}/#{date_id}.json"
        else
          # (Poorly) Handle path expansion.
          if path.include? "~"
            return "I don't know where your home directory is. Please use the full path."
          end
          # Add the default filename if the user gave me a directory
          path = File.expand_path("#{date_id}.json", path) if File.directory? path
        end
        return "That file exists already!" if File.file? path
        # Check to see if I can write there
        return "Can't write to #{path}!" if File.writable? path
        # Write the time stack to the file, in json format.
        File.open(path, "w") { |f| JSON.dump(@time_stack, f) }
        true
      end

      def authed? (user)
        if @allow_op_msgs
          (user.nick == @owner_nick || user.oper?) && (user.authed? || !@has_ns)
        else
          user.nick == @owner_nick && (user.authed? || !@has_ns)
        end
      end

    end
  end
end
