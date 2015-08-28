# openassets-ruby
The implementation of the Open Assets Protocol for Ruby.

## Install

```ruby
gem install openassets-ruby              
```

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

* **list_unspent**  
Returns an array of unspent transaction outputs, argument with the asset ID and quantity of each output.
  ```ruby
  # get all unspent outputs in the wallet.
  api.list_unspent
  
  # specify th open asset address.
  api.list_unspent(['akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6'])
  ``` 

* **get_balance**  
Returns the balance in both bitcoin and colored coin assets for all of the addresses available in your Bitcoin Core wallet.
  ```ruby
  # get all balance in the wallet.
  api.get_balance
  
  # specify the open asset address.
  api.get_balance('akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6')
  ``` 
  
* **issue_asset**  
Creates a transaction for issuing an asset.
  ```ruby
  # issue asset
  # api.issue_asset(<issuer open asset address>, <issuing asset quantity>, <metadata>, <to open asset address>, <fees (The fess in satoshis for the transaction. use 10000 satoshi if specified nil)>, <mode=('broadcast', 'signed', 'unsigned')>, <output_qty default value is 1.>)

  # example
  address = 'akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH'
  api.issue_asset(address, 150, 'u=https://goo.gl/bmVEuw', address, nil, 'broadcast')
  ``` 
If specified ``output_qty``, the issue output is divided by the number of output_qty.   
Ex, amount = 125 and output_qty = 2, the marker output asset quantity is [62, 63] and issue TxOut is two.

* **send_asset**  
Creates a transaction for sending an asset from the open asset address to another.
  ```ruby
  # send asset
  # api.send_asset(<from open asset address>, <asset ID>, <asset quantity>, <to open asset address>, <fees (The fess in satoshis for the transaction. use 10000 satoshi if specified nil)>, <mode=('broadcast', 'signed', 'unsigned')>)

  # example
  from = 'akXDPMMHHBrUrd1fM756M1GSB8viVAwMyBk'
  to = 'akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6'
  api.send_asset(from, 'AWo3R89p5REmoSyMWB8AeUmud8456bRxZL', 100, to, 10000, 'broadcast')
  ``` 
  
* **send_bitcoin**  
Creates a transaction for sending bitcoins from an address to another.  
This transaction inputs use only uncolored outputs.
  ```ruby
  # send bitcoin
  # api.send_bitcoin(<from btc address>, <amount (satoshi)>, <to btc address>, <fees (The fess in satoshis for the transaction. use 10000 satoshi if specified nil)>, <mode=('broadcast', 'signed', 'unsigned')>, <output_qty default value is 1.>)

  # example
  from = '14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6'
  to = '1MFW7BTwiNbAkmVz4SzAMQXboKYKGSzkq2'
  api.send_bitcoin(from, 60000, to)
  ``` 
If specified ``output_qty``, the send output is divided by the number of output_qty.   
Ex, amount = 60000 and output_qty = 2, send TxOut is two (each value is 30000, 30000) and change TxOut one.

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
