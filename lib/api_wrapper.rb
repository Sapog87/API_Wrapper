# frozen_string_literal: true

require_relative "api_wrapper/version"

require "net/http"
require "json"
require "csv"

# Wrap Binance API
module APIWrapper
  PATH = "https://api.binance.com/api/v3/"

  # Class to get raw data from Binance API
  class BinanceRawData
    # Test connectivity to the Rest API and get the current server time
    def time
      path = "#{PATH}time"
      get_and_parse path
    end

    # Current average price for a symbol
    def avg_price(symbol)
      path = "#{PATH}avgPrice?symbol=#{symbol}"
      get_and_parse path
    end

    # Current exchange trading rules and symbol information
    def exchange_info(symbols = "")
      throw ArgumentError.new "symbols can't be #{symbols}" if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?

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

    # Get recent trades
    def trades(symbol, limit = 500)
      throw ArgumentError.new "invalid type(s)" if !symbol.is_a?(String) || !limit.is_a?(Integer)
      throw ArgumentError.new "limit can't be #{limit}" if limit > 1000 || limit < 1

      path = "#{PATH}trades?symbol=#{symbol}&limit=#{limit}"

      get_and_parse path
    end

    # Get compressed, aggregate trades
    def agg_trades(symbol, from_id = 0, limit = 500)
      throw ArgumentError.new "invalid type(s)" if !symbol.is_a?(String) || !limit.is_a?(Integer) || !from_id.is_a?(Integer)
      throw ArgumentError.new "limit can't be #{limit}" if limit > 1000 || limit < 1

      path = "#{PATH}aggTrades?symbol=#{symbol}&limit=#{limit}"
      path += "&fromId=#{from_id}" if from_id.positive?

      get_and_parse path
    end

    # 24 hour rolling window price change statistics
    def ticker_24h(symbols = "", type = "FULL")
      throw ArgumentError.new "symbols can't be #{symbols}" if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?
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

    # Latest price for a symbol or symbols
    def ticker_price(symbols = "")
      throw ArgumentError.new "symbols can't be #{symbols}" if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?

      path = "#{PATH}ticker/price"
      path += "?symbol=" if symbols.is_a?(String) && !symbols.empty?
      path += "?symbols=" if symbols.is_a? Array

      params = symbols.to_s.delete(" ")
      path += params

      get_and_parse path
    end

    # Best price/qty on the order book for a symbol or symbols
    def book_ticker(symbols = "")
      throw ArgumentError.new "symbols can't be #{symbols}" if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?

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
      throw ArgumentError.new "interval can't be #{interval}" unless check_interval(interval)
      path = "#{PATH}klines?symbol=#{symbol}&interval=#{interval}"

      get_and_parse path
    end

    # get recent UIKlines data
    def uiklines_data(symbol, interval = "1s")
      throw ArgumentError.new "symbol can't be #{symbol}" if !symbol.is_a?(String) && symbol.empty?
      throw ArgumentError.new "interval can't be #{interval}" unless check_interval(interval)
      path = "#{PATH}uiKlines?symbol=#{symbol}&interval=#{interval}"

      get_and_parse path
    end

    # get rolling window price change statistics
    def price_change_stats(symbols = "", windowsize = "1d", type = "full")
      throw ArgumentError.new "windowSize can't be #{windowsize}" unless check_windowsize(windowsize)
      throw ArgumentError.new "symbols can't be #{symbols}" if !symbols.is_a?(String) || symbols.empty?
      path = "#{PATH}ticker?symbol=#{symbols}&windowSize=#{windowsize}&type=#{type}"

      get_and_parse path
    end

    # write average prices to a csv file
    # all ~ 2115
    def write_avg_prices_to_csv(count = 10)
      throw ArgumentError.new "count can't be #{count}" if count <= 0

      CSV.open("avg_prices.csv", "w") do |csv|
        csv << %w[Pair Price Time]
      end

      pairs = exchange_info["symbols"].take(count)

      CSV.open("avg_prices.csv", "ab") do |csv|
        pairs.each do |x|
          pair = x["symbol"]
          csv << [pair, avg_price(pair)["price"], Time.now]
        end
      end
    end

    # write average prices to a csv file of certain pairs
    def write_certain_avg_prices_to_csv(symbols = "")
      throw ArgumentError.new "symbols can't be #{symbols}" if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?

      filename = "avg_prices_of #{symbols.join(" ")}.csv"
      CSV.open(filename, "w") do |csv|
        csv << %w[Pair Price Time]
      end

      pairs = exchange_info(symbols)["symbols"]

      CSV.open(filename, "ab") do |csv|
        pairs.each do |x|
          pair = x["symbol"]
          csv << [pair, avg_price(pair)["price"], Time.now]
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
      %w[1s 1m 3m 5m 15m 30m 1h 2h 4h 6h 8h 12h 1d 3d 1w 1M].include?(interval)
    end

    def check_windowsize(_windowsize)
      char = windowsize[-1]
      nums = windowsize[0, windowsize.length - 1].to_i

      (char == "d" && nums >= 1 && nums <= 7) || (char == "h" && nums >= 1 && nums <= 23) || (char == "m" && nums >= 1 && nums <= 59)
    end
  end
end
