# frozen_string_literal: true

require_relative "api_wrapper/version"

require "net/http"
require "json"
require "csv"

# aaa
module APIWrapper
  PATH = "https://api.binance.com/api/v3/"

  # aaa
  class BinanceRawData
    # aaa
    def time
      path = "#{PATH}time"
      get_and_parse path
    end

    # aaa
    def avg_price(symbol)
      path = "#{PATH}avgPrice?symbol=#{symbol}"
      get_and_parse path
    end

    # aaa
    def exchange_info(symbols = "")
      if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?
        throw ArgumentError.new "symbols can't be #{symbols}"
      end

      path = "#{PATH}exchangeInfo"
      path += "?symbol=" if symbols.is_a?(String) && !symbols.empty?
      path += "?symbols=" if symbols.is_a? Array

      params = symbols.to_s.delete(" ")
      path += params

      get_and_parse path
    end

    # aaa
    def depth(symbol, limit = 500)
      throw ArgumentError.new "symbol can't be #{symbol}" if !symbol.is_a?(String) && symbol.empty?
      throw ArgumentError.new "limit can't be #{limit}" if limit > 5000 || limit < 1

      path = "#{PATH}depth?symbol=#{symbol}&limit=#{limit}"

      get_and_parse path
    end

    # aaa
    def trades(symbol, limit = 500)
      throw ArgumentError.new "invalid type(s)" if !symbol.is_a?(String) || !limit.is_a?(Integer)
      throw ArgumentError.new "limit can't be #{limit}" if limit > 1000 || limit < 1

      path = "#{PATH}trades?symbol=#{symbol}&limit=#{limit}"

      get_and_parse path
    end

    # aaa
    def agg_trades(symbol, from_id = 0, limit = 500)
      throw ArgumentError.new "invalid type(s)" if !symbol.is_a?(String) || !limit.is_a?(Integer) || !from_id.is_a?(Integer)
      throw ArgumentError.new "limit can't be #{limit}" if limit > 1000 || limit < 1

      path = "#{PATH}aggTrades?symbol=#{symbol}&limit=#{limit}"
      path += "&fromId=#{from_id}" if from_id.positive?

      get_and_parse path
    end

    # aaa
    def ticker_24h(symbols = "", type = "FULL")
      if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?
        throw ArgumentError.new "symbols can't be #{symbols}"
      end
      throw ArgumentError.new "type can't be #{type}" if type != "FULL" && type != "MINI"

      separator = "?"

      path = "#{PATH}ticker/24hr"

      if symbols.is_a?(String) && !symbols.empty?
        path += "#{separator}symbol="
        separator = "&"
      end
      if symbols.is_a? Array
        path += "#{separator}symbols="
        separator = "&"
      end

      params = symbols.to_s.delete(" ")
      path += params

      path += "#{separator}type=MINI" if type == "MINI"

      get_and_parse path
    end

    # aaa
    def ticker_price(symbols = "")
      if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?
        throw ArgumentError.new "symbols can't be #{symbols}"
      end

      path = "#{PATH}ticker/price"
      path += "?symbol=" if symbols.is_a?(String) && !symbols.empty?
      path += "?symbols=" if symbols.is_a? Array

      params = symbols.to_s.delete(" ")
      path += params

      get_and_parse path
    end

    # aaa
    def book_ticker(symbols = "")
      if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?
        throw ArgumentError.new "symbols can't be #{symbols}"
      end

      path = "#{PATH}ticker/bookTicker"
      path += "?symbol=" if symbols.is_a?(String) && !symbols.empty?
      path += "?symbols=" if symbols.is_a? Array

      params = symbols.to_s.delete(" ")
      path += params

      get_and_parse path
    end

    # get recent Kline data
    def kline_data(symbol, interval = "1s")
      throw ArgumentError.new "symbol can't be #{symbol}" if !symbol.is_a?(String) && symbol.empty?
      throw ArgumentError.new "interval can't be #{interval}" if !check_interval(interval)
      path = "#{PATH}klines?symbol=" + symbol + "&interval=" + interval

      get_and_parse path
    end

    # get recent UIKlines data
    def uiklines_data(symbol, interval = "1s")
      throw ArgumentError.new "symbol can't be #{symbol}" if !symbol.is_a?(String) && symbol.empty?
      throw ArgumentError.new "interval can't be #{interval}" if !check_interval(interval)
      path = "#{PATH}uiKlines?symbol=" + symbol + "&interval=" + interval

      get_and_parse path
    end

    # get rolling window price change statistics
    def price_change_stats(symbols = "", windowSize = "1d", type = "full") 
      throw ArgumentError.new "windowSize can't be #{windowSize}" if !check_windowsize(windowSize)
      throw ArgumentError.new "symbols can't be #{symbols}" if !symbols.is_a?(String) || symbols.empty?
      path = "#{PATH}ticker?symbol=" + symbols + "&windowSize=" + windowSize + "&type=" + type

      get_and_parse path
    end

    # write average prices to a csv file
    # all ~ 2115
    def write_avg_prices_to_csv(count = 10)
      throw ArgumentError.new "count can't be #{count}" if(count <= 0)

      CSV.open("avg_prices.csv", "w") do |csv|
        csv << ["Pair", "Price", "Time"]
      end

      pairs = exchange_info()['symbols'].take(count)

      CSV.open("avg_prices.csv", "ab") do |csv|
        for x in pairs
          pair = x['symbol']
          csv << [pair, avg_price(pair)['price'], Time.now]
        end
      end
    end

    # write average prices to a csv file of certain pairs
    def write_certain_avg_prices_to_csv(symbols = "")
      if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?
        throw ArgumentError.new "symbols can't be #{symbols}"
      end

      filename = "avg_prices_of " + symbols.join(' ') + ".csv"
      CSV.open(filename, "w") do |csv|
        csv << ["Pair", "Price", "Time"]
      end

      pairs = exchange_info(symbols)['symbols']

      CSV.open(filename, "ab") do |csv|
        for x in pairs
          pair = x['symbol']
          csv << [pair, avg_price(pair)['price'], Time.now]
        end
      end
    end

    private

    def get_and_parse(path)
      uri = URI.parse path
      http = Net::HTTP.get uri
      JSON.parse http
    end

    def check_interval(interval)
      interval == '1s' || '1m' || '3m' || '5m' || '15m' || '30m' || '1h' || '2h' || '4h' || '6h' || '8h' || '12h' || '1d' || '3d' || '1w' || '1M'
    end

    def check_windowsize(windowSize)
      char = windowSize[-1]
      nums = windowSize[0, windowSize.length - 1].to_i
      
      (char == 'd' && nums >= 1 && nums <= 7) || (char == 'h' && nums >= 1 && nums <= 23) || (char == 'm' && nums >= 1 && nums <= 59)
    end

  end  
end

t = APIWrapper::BinanceRawData.new
t.write_avg_prices_to_csv(100)
p t.exchange_info(['BTCUSDT', 'ETHBTC'])
t.write_certain_avg_prices_to_csv(['BTCUSDT', 'ETHBTC', 'ETHRUB'])