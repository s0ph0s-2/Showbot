require 'open-uri'
require 'json'
require 'openssl'
require 'cinch/cooldown'

module Cinch
  module Plugins
    class Bittick
      include Cinch::Plugin

      enforce_cooldown

      match /bittick/i,   :method => :command_btcetick
      match /btcetick/i,  :method => :command_btcetick
      match /bitavg/i,    :method => :command_bitavg
      match /dogetick/i,  :method => :command_dogetick
      match /litetick/i,  :method => :command_litetick

      def help
        [
          '!bitavg - Bitcoin averages from bitcoinaveages.com',
          '!btcetick - Bitcoin Ticker (BTC-E)',
          '!dogetick - Dogecoin Ticker (BTer)'
        ].join "\n"
      end

      def help_btcetick
        [
          '!btcetick - Bitcoin Ticker (BTC-E)',
          'Usage: !btcetick'
        ].join "\n"
      end

      def help_bitavg
        [
          '!bitavg - Bitcoin averages from bitcoinaveages.com',
          'Usage: !bitavg'
        ].join "\n"
      end

      def help_dogetick
        [
          '!dogetick - Dogecoin Ticker (BTer)',
          'Usage: !dogetick'
        ].join "\n"
      end

      def help_litetick
        [
          '!litetick - Litecoin Ticker (BTC-E)',
          'Usage: !litetick'
        ].join "\n"
      end

      def command_btcetick(m)
        btcejson = open('https://btc-e.com/api/2/btc_usd/ticker').read
        btcedata = JSON::parse(btcejson)["ticker"]
        btcedata["avg"] = "%.2f" % btcedata["avg"]
        btcedata["high"] = "%.2f" % btcedata["high"]
        btcedata["low"] =  "%.2f" % btcedata["low"]
        btcedata['vol'] = "%.2f" % btcedata['vol']

        m.reply "#{Format(:blue,'BTC-E:')} #{Format(:bold,'Average:')} #{Format(:orange,'$%<average>s')} #{Format(:bold,'Last:')} #{Format(:orange,'$%<last>s')} #{Format(:bold,'High:')} #{Format(:orange,'$%<high>s')} #{Format(:bold,'Low:')} #{Format(:orange,'$%<low>s')} #{Format(:bold,'Volume:')} #{Format(:orange,'$%<vol>s')}" % {
            average: btcedata['avg'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2'),
            last: btcedata['last'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2'),
            high: btcedata['high'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2'),
            low: btcedata['low'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2'),
            vol: btcedata['vol'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
          }
      end

      def command_bitavg(m)
        bitavgjson = open('https://api.bitcoinaverage.com/ticker/global/USD/').read
        bitavgdata = JSON::parse(bitavgjson)

        m.reply "#{Format(:blue,'BitcoinAverage:')} #{Format(:bold,'24h Average:')} #{Format(:orange,'$%<average>s')} #{Format(:bold,'Last:')} #{Format(:orange,'$%<last>s')} #{Format(:bold,'Ask:')} #{Format(:orange,'$%<ask>s')} #{Format(:bold,'Bid:')} #{Format(:orange,'$%<bid>s')} #{Format(:bold,'Volume:')} #{Format(:orange,'%<vol>s BTC')}" % {
            average: bitavgdata['24h_avg'],
            last: bitavgdata['last'],
            ask: bitavgdata['ask'],
            bid: bitavgdata['bid'],
            vol: bitavgdata['volume_btc'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
          }
      end

      def command_dogetick(m)
        dogejson = open('https://data.bter.com/api/1/ticker/doge_btc').read
        dogedata = JSON::parse(dogejson)

        m.reply "#{Format(:blue,'BTer:')} #{Format(:bold,'24h Average:')} #{Format(:orange,'%<average>s BTC')} #{Format(:bold,'Last:')} #{Format(:orange,'%<last>s BTC')} #{Format(:bold,'Ask:')} #{Format(:orange,'%<ask>s BTC')} #{Format(:bold,'Bid:')} #{Format(:orange,'%<bid>s BTC')} #{Format(:bold,'Volume:')} #{Format(:orange,'%<vol>s DOGE')}" % {
            average: dogedata['avg'],
            last: dogedata['last'],
            ask: dogedata['sell'],
            bid: dogedata['buy'],
            vol: dogedata['vol_doge'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
          }
      end

      def command_litetick(m)
        json = open('https://btc-e.com/api/2/ltc_usd/ticker').read
        data = JSON::parse(json)["ticker"]

        last = "%0.2f" % data['last']
        high = "%0.2f" % data['high']
        low = "%0.2f" % data['low']
        vol = data['vol'].to_s.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse
        avg = "%0.2f" % data['avg']

        m.reply "#{Format(:bold,'Average:')} #{Format(:orange,'$%<average>s')} #{Format(:bold,'Last:')} #{Format(:orange,'$%<last>s')} #{Format(:bold,'High:')} #{Format(:orange,'$%<high>s')} #{Format(:bold,'Low:')} #{Format(:orange,'$%<low>s')} #{Format(:bold,'Volume:')} #{Format(:orange,'%<vol>s LTC')}" % {
          average: avg,
          last: last,
          high: high,
          low: low,
          vol: vol
        }
      end
    end
  end
end

