# frozen_string_literal: true

require_relative "api_wrapper/version.rb"

require "net/http"
require "json"

# aaa
module APIWrapper
  PATH = "https://api.binance.com/api/v3/"

  # aaa
  class BinanceRawData
    # aaa
    def time
      path = PATH + "time"
      get_and_parse path
    end

    # aaa
    def avg_price(symbol)
      path = PATH + "avgPrice?symbol=" + symbol
      get_and_parse path
    end

    # aaa
    def exchange_info(symbols = "")
      if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?
        throw ArgumentError.new "symbols can't be " + symbols.to_s
      end

      path = PATH + "exchangeInfo"
      path += "?symbol=" if symbols.is_a?(String) && !symbols.empty?
      path += "?symbols=" if symbols.is_a? Array

      params = symbols.to_s.delete(" ")
      path += params

      get_and_parse path
    end

    # aaa
    def depth(symbol, limit = 500)
      throw ArgumentError.new "symbol can't be " + symbol.to_s if !symbol.is_a?(String) && symbol.empty?
      throw ArgumentError.new "limit can't be " + limit.to_s if limit > 5000 || limit < 1

      path = PATH + "depth?symbol=" + symbol + "&limit=" + limit.to_s

      get_and_parse path
    end

    # aaa
    def trades(symbol, limit = 500)
      throw ArgumentError.new "invalid type(s)" if !symbol.is_a?(String) || !limit.is_a?(Integer)
      throw ArgumentError.new "limit can't be " + limit.to_s if limit > 1000 || limit < 1

      path = PATH + "trades?symbol=" + symbol + "&limit=" + limit.to_s

      get_and_parse path
    end

    # aaa
    def agg_trades(symbol, from_id = 0, limit = 500)
      throw ArgumentError.new "invalid type(s)" if !symbol.is_a?(String) || !limit.is_a?(Integer) || !from_id.is_a?(Integer)
      throw ArgumentError.new "limit can't be " + limit.to_s if limit > 1000 || limit < 1

      path = PATH + "aggTrades?symbol=" + symbol + "&limit=" + limit.to_s
      path += "&fromId=" + from_id.to_s if from_id.positive?

      get_and_parse path
    end

    # aaa
    def ticker_24h(symbols = "", type = "FULL")
      if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?
        throw ArgumentError.new "symbols can't be " + symbols.to_s
      end
      throw ArgumentError.new "type can't be " + type.to_s if type != "FULL" && type != "MINI"

      separator = "?"

      path = PATH + "ticker/24hr"

      if symbols.is_a?(String) && !symbols.empty?
        path += separator + "symbol="
        separator = "&"
      end
      if symbols.is_a? Array
        path += separator + "symbols="
        separator = "&"
      end

      params = symbols.to_s.delete(" ")
      path += params

      path += separator + "type=MINI" if type == "MINI"

      get_and_parse path
    end

    # aaa
    def ticker_price(symbols = "")
      if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?
        throw ArgumentError.new "symbols can't be " + symbols.to_s
      end

      path = PATH + "ticker/price"
      path += "?symbol=" if symbols.is_a?(String) && !symbols.empty?
      path += "?symbols=" if symbols.is_a? Array

      params = symbols.to_s.delete(" ")
      path += params

      get_and_parse path
    end

    # aaa
    def book_ticker(symbols = "")
      if !symbols.is_a?(Array) && !symbols.is_a?(String) || symbols.is_a?(Array) && symbols.empty?
        throw ArgumentError.new "symbols can't be " + symbols.to_s
      end

      path = PATH + "ticker/bookTicker"
      path += "?symbol=" if symbols.is_a?(String) && !symbols.empty?
      path += "?symbols=" if symbols.is_a? Array

      params = symbols.to_s.delete(" ")
      path += params

      get_and_parse path
    end

    private

    def get_and_parse(path)
      uri = URI.parse path
      http = Net::HTTP.get uri
      JSON.parse http
    end
  end

  # binance = APIWrapper::BinanceRawData.new
  #
  # puts binance.time
  #
  # puts binance.avg_price "BTCUSDT"
  #
  # puts binance.exchange_info %w[BTCUSDT BNBBTC ETHBTC]
  # puts binance.exchange_info ["BTCUSDT"]
  # puts binance.exchange_info "BTCUSDT"
  # puts binance.exchange_info
  #
  # puts binance.depth "BTCUSDT"
  # puts binance.depth "BTCUSDT", 10
  #
  # puts binance.trades "BTCUSDT"
  # puts binance.trades "BTCUSDT", 10
  #
  # puts binance.agg_trades "BTCUSDT"
  # puts binance.agg_trades "BTCUSDT", 0
  # puts binance.agg_trades "BTCUSDT", 0, 10
  #
  # puts binance.ticker_24h %w[BTCUSDT BNBBTC ETHBTC]
  # puts binance.ticker_24h %w[BTCUSDT BNBBTC ETHBTC], "MINI"
  # puts binance.ticker_24h ["BTCUSDT"]
  # puts binance.ticker_24h ["BTCUSDT"], "MINI"
  # puts binance.ticker_24h "BTCUSDT"
  # puts binance.ticker_24h "BTCUSDT", "MINI"
  # puts binance.ticker_24h "", "MINI"
  # puts binance.ticker_24h
  #
  # puts binance.ticker_price %w[BTCUSDT BNBBTC ETHBTC]
  # puts binance.ticker_price ["BTCUSDT"]
  # puts binance.ticker_price "BTCUSDT"
  # puts binance.ticker_price
  #
  # puts binance.book_ticker %w[BTCUSDT BNBBTC ETHBTC]
  # puts binance.book_ticker ["BTCUSDT"]
  # puts binance.book_ticker "BTCUSDT"
  # puts binance.book_ticker
end
