# APIWrapper

Gem that wraps Binance API

https://binance-docs.github.io/apidocs/#market-data-endpoints

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'API_Wrapper'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install API_Wrapper

## Usage

    #symbol = "BTCUSDT"
    
    binance = APIWrapper::BinanceRawData.new

    # Current average price for a symbol
    def avg_price(symbol)

    # Current exchange trading rules and symbol information
    def exchange_info(symbols)

    # Get depth
    def depth(symbol, limit)

    # Get recent trades
    def trades(symbol, limit)

    # Get compressed, aggregate trades
    def agg_trades(symbol, from_id, limit)

    # 24 hour rolling window price change statistics
    def ticker_24h(symbols, type)

    # Latest price for a symbol or symbols
    def ticker_price(symbols)

    # Best price/qty on the order book for a symbol or symbols
    def book_ticker(symbols)

    # get recent Kline data
    def kline_data(symbol, interval)

    # get recent UIKlines data
    def uiklines_data(symbol, interval)

    # get rolling window price change statistics
    def price_change_stats(symbols, windowsize, type)

    # write average prices to a csv file
    # all ~ 2115
    def write_avg_prices_to_csv(count)

    # write average prices to a csv file of certain pairs
    def write_certain_avg_prices_to_csv(symbols)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Sapog87/API_Wrapper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/API_Wrapper/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the APIWrapper project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/API_Wrapper/blob/master/CODE_OF_CONDUCT.md).
