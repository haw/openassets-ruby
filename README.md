# openassets-ruby
The implementation of the Open Assets Protocol for Ruby.

## Configuration

Initialize the connection information to the Bitcoin Core server.

```ruby
require 'openassets'

api = OpenAssets::Api.new({:network => 'mainnet',
                     :provider => 'bitcoind',
                     :dust_limit => 600,
                     :rpc => {:user => 'xxx', :password => 'xxx', :schema => 'http', :port => 8332, :host => 'localhost'}})                      
```

## API

Currently openassets-ruby support the following API.   
(The other API is in development. ex, issue_asset, send_asset)

* list_unspent  
Returns an array of unspent transaction outputs, augmented with the asset ID and quantity of each output.
  ```ruby
  # get all unspent outputs in the wallet.
  api.list_unspent
  
  # specify th open asset address.
  api.list_unspent(['akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6'])
  ``` 

* get_balance  
Returns the balance in both bitcoin and colored coin assets for all of the addresses available in your Bitcoin Core wallet.
  ```ruby
  # get all balance in the wallet.
  api.get_balance
  
  # specify the open asset address.
  api.get_balance('akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6')
  ``` 

## License

The MIT License (MIT)

Copyright (c) 2015 HAW International Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
