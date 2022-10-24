# frozen_string_literal: true

require "test_helper"

class TestAPIWrapper < Minitest::Test
  def test_time
    binance = APIWrapper::BinanceRawData.new
    assert !binance.time["serverTime"].nil?
  end

  def test_avg_price
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.avg_price("AAA")["code"], -1121
    assert !binance.avg_price("BTCUSDT")["price"].nil?
  end

  def test_depth
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.depth("-AAA")["code"], -1121
    assert !binance.depth("BTCUSDT")["lastUpdateId"].nil?
    assert_equal binance.depth("BTCUSDT", 200)["bids"].size, 200
  end

  def test_trades
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.trades("-AAA")["code"], -1121
    assert binance.trades("BTCUSDT").is_a?(Array)
    assert_equal binance.trades("BTCUSDT", 200).size, 200
  end

  def test_agg_trades
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.agg_trades("-AAA")["code"], -1121
    assert binance.agg_trades("BTCUSDT").is_a?(Array)
    assert_equal binance.agg_trades("BTCUSDT", 20_000)[0]["a"], 20_000
    assert_equal binance.agg_trades("BTCUSDT", 0, 200).size, 200
  end

  def test_ticker_24h
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.ticker_24h("-AAA")["code"], -1121
    assert_equal binance.ticker_24h("BTCUSDT")["symbol"], "BTCUSDT"
    assert_equal binance.ticker_24h("BTCUSDT").size, 21
    assert_equal binance.ticker_24h(%w[BTCUSDT BNBBTC ETHBTC]).size, 3
    assert_equal binance.ticker_24h(%w[BTCUSDT BNBBTC ETHBTC], "MINI")[0].size, 12
    assert binance.ticker_24h("", "MINI").is_a?(Array)
  end

  def test_ticker_price
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.ticker_price("-AAA")["code"], -1121
    assert_equal binance.ticker_price(%w[BTCUSDT BNBBTC ETHBTC]).size, 3
    assert binance.ticker_price(["BTCUSDT"]).is_a?(Array)
    assert !binance.ticker_price("BTCUSDT")["price"].nil?
    assert binance.ticker_price.is_a?(Array)
  end

  def test_book_ticker
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.book_ticker("-AAA")["code"], -1121
    assert_equal binance.book_ticker(%w[BTCUSDT BNBBTC ETHBTC]).size, 3
    assert binance.book_ticker(["BTCUSDT"]).is_a?(Array)
    assert_equal binance.book_ticker("BTCUSDT")["symbol"], "BTCUSDT"
    assert binance.book_ticker.is_a?(Array)
  end

  def test_exchange_info
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.exchange_info("-AAA")["code"], -1121
    assert_equal binance.exchange_info(%w[BTCUSDT BNBBTC ETHBTC])["symbols"].size, 3
    assert !binance.exchange_info("BTCUSDT")["symbols"].nil?
    assert !binance.exchange_info["symbols"].empty?
  end

  def test_kline_data
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.kline_data('-A')["code"], -1121
  end

  def uiklines_data
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.uiklines_data('-A')["code"], -1121
  end

  def price_change_stats
    binance = APIWrapper::BinanceRawData.new
    assert_equal binance.price_change_stats('-A')["code"], -1121
  end
end
