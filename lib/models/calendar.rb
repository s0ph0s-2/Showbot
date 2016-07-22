require 'google/api_client'
require 'chronic_duration'
require 'tzinfo'
require './lib/models/shows'
require './lib/models/timehash'

# The Calendar module provides access to remote calendars to JBot plugins. It
# currently pulls events from a Google Calendar as the default backend. The
# events are filtered so that only live events (where the title starts with
# 'LIVE: ') are fetched. To get a Calendar object, use
# `Calendar.new(config_data)` to get a duck-typed Calendar object that meets the
# following interface:
#
#   Calendar#events: returns an array of Calendar::CalendarEvents
#
# A Calendar::CalendarEvent object holds basic event data, and provides the
# following (read-only) attributes:
#
#   summary:    (string) The title of the event, with 'LIVE: ' prefix removed.
#   start_time: (DateTime) The start time of the event.
#   end_time:   (DateTime) The end time of the event.
module Calendar
  # Create a new Calendar object, here a GoogleCalendar object. This method is a
  # factory method to get a Calendar duck-subtype object.
  # A Calendar object fetches a remote calendar feed. Those events can then be
  # retrieved as an array of Calendar::CalendarEvent objects.
  #
  # param config: The `config` parameter is a hash of configuration data.
  # Currently, it pulls in the parameters required to call out to the Google
  # Calendar API. A simple way to have all this set is to pass the Cinch plugin
  # config object into this method, and set all the required fields in the
  # cinchize.yml config file. The hash has the following required keys:
  #
  #   app_name:    The name of your application
  #   app_version: The version of your application
  #   calendar_id: The Google Calendar ID of the calendar you want to use
  #   api_key:     Your API key for the Google Calendar API
  #
  # The `app_name` and `app_version` fields can be arbitrary, and are for
  # Google's use. The calendar_id is of the form:
  #
  #   CALENDARIDHERE@group.calendar.google.com
  #
  # and is embedded in your calendar's URLs. The api_key must be obtained from
  # Google through their API Console at https://code.google.com/apis/console
  #
  # TODO: Right now, this errors out on missing/invalid config. It should
  #   instead return a NullCalendar object that returns no events.
  def self.new(config = {})
    # google_config = {
    #   :app_name => config[:app_name],
    #   :app_version => config[:app_version],
    #   :calendar_id => config[:calendar_id],
    #   :api_key => config[:api_key]
    # }

    # google_client = Google::APIClient.new(
    #   :application_name => google_config[:app_name],
    #   :application_version => google_config[:app_version],
    #   :key => google_config[:api_key],
    #   :authorization => nil
    # )

    # google_api = google_client.discovered_api('calendar', 'v3')

    # GoogleCalendar.new(google_config, google_client, google_api)
    XBNCalendar.new(config)
  end

  # The Calendar::GoogleCalendar class provides the default backend for Calendar
  class GoogleCalendar
    # param config: (hash) A config hash with the keys:
    #
    #   app_name:    The name of your application
    #   app_version: The version of your application
    #   calendar_id: The Google Calendar ID of the calendar you want to use
    #   api_key:     Your API key for the Google Calendar API
    #
    # param client: (Google::APIClient) A Google API client object
    # param api: (Google::APIClient::API) A Google API object, obtained from
    #   calling the `Google::APIClient#discovered_api` method.
    def initialize(config, client, api)
      @config = config
      @client = client
      @calendar = api
    end

    # Get live events for the next 7 days
    # Live events start with "LIVE: "
    # Returns an array of CalendarEvent objects
    # Events are ordered by start time, ascending
    # The "LIVE: " prefix is stripped from the event summary
    def events
      results = @client.execute(
        :api_method => @calendar.events.list,
        :authenticated => false,
        :parameters => {
          'calendarId' => @config[:calendar_id],
          'fields' => 'items(start,end,summary)',
          'singleEvents' => true,
          'orderBy' => 'startTime',
          'timeMin' => DateTime.now.to_s,
          'timeMax' => (DateTime.now + 7).to_s,
          'q' => 'LIVE'
        }
      )

      results.data.items.map do |event|
        summary = event.summary.gsub(/^LIVE:\s+/, '')
        CalendarEvent.new(summary, event.start.date_time, event.end.date_time)
      end
    end
  end

  # The XBNCalendar class provides an alternate backend for Calendar. Instead
  # of connecting to a Google Calendar, it utilizes information provided by a
  # NetTimeHash, which holds Times scraped from webpages.
  class XBNCalendar
    # Create the NetTimeHash
    def initialize(config = {})
      @countdowns = NetTimeHash::NetTimeHash.new config
    end

    # Get the next show time for each show being tracked.
    # Returns an array of CalendarEvent objects, sorted by ascending time
    def events
      events = []
      @countdowns.times.each do |id, show_time|
        events << CalendarEvent.new(
          Shows.find_show(id.to_s),
          show_time.latest,
          show_time.latest + (60*60*3)
        )
      end
      events.sort! {|a,b| b.start_time <=> a.start_time}
    end
  end

  # The CalendarEvent class holds data for individual events. It is provided to
  # encapsulate any variations in calendar data back-ends. It has the following
  # (read-only) attributes:
  #
  #   summary:    (string) The title of the event, with 'LIVE: ' prefix removed.
  #   start_time: (DateTime) The start time of the event.
  #   end_time:   (DateTime) The end time of the event.
  class CalendarEvent
    attr_reader :summary
    attr_reader :start_time
    attr_reader :end_time

    def initialize(summary, start_time, end_time)
      @summary = summary
      @start_time = start_time
      @end_time = end_time
    end

    # Determine of an event covers a time (is between event start and end)
    def covers?(time)
      start_time <= time && time < end_time
    end

    # Determine if an event starts after a time
    def after?(time)
      start_time > time
    end

    # Output a fancy breakdown of time until event
    def fancy_time_until
      ChronicDuration.output(seconds_until, :format => :long)
    end

    # Get the number of seconds until event starts
    # returns: (int) Seconds until start
    def seconds_until
      (start_time - Time.now).to_i
    end

    # Convert start date to local string
    def start_date_to_local_string(tz = TZInfo::Timezone.get('UTC'))
      tz.strftime("%A, %-m/%-d/%Y", start_time.utc)
    end

    # Convert start time to local string
    def start_time_to_local_string(tz = TZInfo::Timezone.get('UTC'))
      tz.strftime("%-I:%M%P %Z", start_time.utc)
    end
  end
end
