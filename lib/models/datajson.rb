require 'json'
require 'net/https'
require 'eat'

module DataJSON
  def self.new(path)
    data_json = DataJSON.new(persistence_for path)
    data_json.read if data_json.accessible?
    data_json
  end

  private

  def self.persistence_for(path)
    persistence = if path.nil? || path.empty?
        Persistence::NilPersistence.new
      elsif path =~ /^https?:\/\//i
        Persistence::HTTPPersistence.new(path)
      else
        Persistence::FilePersistence.new(path)
      end

    persistence
  end

  class DataJSON
    attr_reader :slug
    attr_reader :title
    attr_reader :started_at

    def initialize(persistence)
      @live = false
      @written = false
      @data_json = persistence
    end

    def accessible?
      @data_json.accessible?
    end

    def read
      begin
        json = JSON.load @data_json.read
      rescue JSON::ParserError => err
        raise IOError, "DataJSON could not be parsed: #{err}", err.backtrace
      end

      self.live = json[:live]
      if !json[:broadcast].nil?
        self.slug = json[:broadcast][:slug]
        self.title = json[:broadcast][:title]
        @started_at = json[:broadcast][:started_at]
      end

      @written = true
    end

    def written?
      @written
    end

    def write(started_at = DateTime.now)
      @started_at = started_at

      @data_json.write to_json

      @written = true
    end

    def live?
      @live
    end

    def live=(live)
      @live = !!live
      @written = false
    end

    def slug=(slug)
      @slug = slug
      @written = false
    end

    def title=(title)
      @title = title
      @written = false
    end

    def to_json(*args)
      data = {
        :live => live?
      }

      if live?
        data[:broadcast] = {
          :slug => slug,
          :title => title,
          :started_at => started_at
        }
      end

      args.length == 0 ?
        data.to_json :
        data.to_json(args)
    end

    def start_show(show)
      self.live = true
      self.slug = show.url
      self.title = show.title
      write
    end

    def end_show
      self.live = false
      self.slug = nil
      self.title = nil
      write
    end
  end

  module Persistence
    class FilePersistence
      attr_reader :file_path
      alias_method :path, :file_path

      def initialize(path)
        @file_path = canonicalize path
      end

      def accessible?
        File.file?(file_path) && File.readable?(file_path)
      end

      def read
        contents = ''

        raise IOError, "File #{file_path} cannot be read." unless accessible?

        open(file_path, 'r') do |file|
          contents = file.read
        end

        contents
      end

      def write(contents)
        open(file_path, 'w') do |file|
          file.write contents
        end
      end

      private

      def absolute?(path)
        path[0] == '/'
      end

      def canonicalize(path)
        path = relativize path unless absolute? path
        File.expand_path path
      end

      def relativize(path)
        File.join File.dirname(__FILE__), "../../#{path}"
      end
    end

    class HTTPPersistence
      attr_reader :http_path
      alias_method :path, :http_path

      def initialize(path)
        @http_path = path
      end

      def accessible?
        uri = URI(http_path)

        begin
          http = Net::HTTP.new(uri.host, uri.port)
          # TODO: Handle HTTPS paths correctly
          # http.use_ssl = true                           # If using SSL
          # http.verify_mode = OpenSSL::SSL::VERIFY_NONE  # Don't verify SSL

          request = Net::HTTP::Head.new(uri.path)
          response = http.request(request)

          # We don't do redirects or anything like that
          response.code == 200
        rescue
          # It's not accesible, but we should probably do more here
          false
        end
      end

      def read
        raise IOError, "HTTP remote #{http_path} cannot be read." unless accessible?
        eat(http_path)
      end

      def write(contents)
        # TODO: PUT request
        raise IOError, 'Not there yet.'
      end
    end

    class NilPersistence
      def path
        ''
      end

      def accessible?
        false
      end

      def read
        raise IOError, 'Persistence layer is not available.'
      end

      def write(contents)
        raise IOError, 'Persistence layer is not available.'
      end
    end
  end
end
