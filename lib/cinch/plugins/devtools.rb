require 'cinch/cooldown'
require 'objspace'

module Cinch
  module Plugins
    class DevTools
      include Cinch::Plugin

      enforce_cooldown

      match /plugins\s*$/i,           :method => :command_list_plugins
      match /resources\s*$/i,         :method => :command_all_resources
      match /resources\s+(.*)\s*$/i,  :method => :command_resources

      def command_list_plugins(m)
        m.reply plugins.join ', '
      end

      def command_all_resources(m)
        stats = {}

        each_plugin do |root_object, plugin_name|
          total_memory = total_memory_for root_object
          stats[plugin_name] = 0 unless stats.has_key? plugin_name
          stats[plugin_name] = stats[plugin_name] + total_memory
        end

        average = average_usage stats
        standard_deviation = standard_deviation_of stats

        m.reply "#{plugin_count} plugins, average: #{average}, std deviation: #{standard_deviation}"

        stats.each_pair do |key, value|
          m.reply "#{Format(:bold, key.to_s)}: #{highlight_value(value, average, standard_deviation)}"
        end
      end

      def command_resources(m, plugin_name)
        each_plugin_named(plugin_name) do |root_object, plugin_name|
          m.reply "#{Format(:bold, plugin_name.to_s)}: #{total_memory_for root_object}"

          objects_in(root_object).select do |obj|
            !(['Class', 'Cinch::Bot'].include? obj.class.name)
          end.each do |obj|
            m.reply "  #{Format(:bold, obj.class.name.to_s)}: #{total_memory_for obj}"
          end
        end
      end

      private

      def plugins
        Cinch::Plugins.constants
      end

      def plugin_count
        plugins.size
      end

      def plugin_for(plugin_name)
        Cinch::Plugins.const_get plugin_name
      end

      def each_plugin
        plugins.each do |plugin_name|
          each_plugin_named(plugin_name) do |root_object, plugin_name|
            yield root_object, plugin_name
          end
        end
      end

      def each_plugin_named(plugin_name)
        ObjectSpace.each_object(plugin_for plugin_name) do |root_object|
          yield root_object, plugin_name
        end
      end

      def objects_in(root_object)
        ObjectSpace.reachable_objects_from root_object
      end

      def total_memory_for(root_object)
        ObjectSpace.memsize_of(root_object) + objects_in(root_object).map do |obj|
          ObjectSpace.memsize_of obj
        end.reduce(0, :+)
      end

      def average_usage(stats)
        stats.values.reduce(0, :+) / stats.size
      end

      def variance_of(stats)
        mean = average_usage stats
        sum = stats.values.map do |value|
          (value - mean) ** 2
        end.reduce(0, :+)

        sum / (stats.size - 1)
      end

      def standard_deviation_of(stats)
        Math.sqrt(variance_of stats).floor
      end

      def highlight_value(value, average, standard_deviation)
        if value > average + 2 * standard_deviation
          Format(:red, value.to_s)
        elsif value > average + standard_deviation
          Format(:orange, value.to_s)
        elsif value > average + standard_deviation / 2
          Format(:yellow, value.to_s)
        else
          Format(:green, value.to_s)
        end
      end
    end
  end
end
