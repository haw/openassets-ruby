# openassets-ruby
The implementation of the Open Assets Protocol for Ruby.

## Install

```ruby
gem install openassets-ruby              
```

## Configuration

Initialize the connection information to the Bitcoin Core server.

* **use mainnet**  
```ruby
require 'openassets'

api = OpenAssets::Api.new({:network => 'mainnet',
                     :provider => 'bitcoind',
                     :dust_limit => 600,
                     :rpc => {:user => 'xxx', :password => 'xxx', :schema => 'http', :port => 8332, :host => 'localhost'}})                      
```

* **use testnet**  
change :network and :port(depends on your server setting).
```ruby
require 'openassets'

api = OpenAssets::Api.new({:network => 'testnet',
                     :provider => 'bitcoind',
                     :dust_limit => 600,
                     :rpc => {:user => 'xxx', :password => 'xxx', :schema => 'http', :port => 18332, :host => 'localhost'}})                      
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
  
  > [
      {
        "txid": "1610a1f62597a3ea36e09e78354be22d2a958c1a38ed9e5d3f1c2811ee82dc37",
        "vout": 1,
        "address": "1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG",
        "oa_address": "akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6",
        "script": "76a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac",
        "amount": "0.00000600",
        "confirmations": 8338,
        "asset_id": "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
        "account": "openassets-ruby",
        "asset_quantity": "67",
        "asset_amount": "6.7",
        "asset_definition_url": "http://goo.gl/fS4mEj"
      },
      ...
  ``` 
  Output items are as follows.
  
  |Item|description|
  |:---|:---|
  |txid|The TXID of the transaction containing the output.|
  |address| A P2PKH or P2SH address.|
  |oa_address|The Open Asset address.|
  |script|The output script.|
  |amount|The Bitcoin amount.|
  |confirmations|A score indicating the number of blocks on the best block chain that would need to be modified to remove or modify a particular transaction. |
  |asset_id|The asset ID is a 160 bits hash, used to uniquely identify the asset stored on the output.|
  |account|The name of an account.|
  |asset_quantity|The asset quantity is an unsigned integer representing how many units of that asset are stored on the output.|
  |asset_amount| The asset amount is the value obtained by converting the asset quantity to the unit of divisibility that are defined in the Asset definition file. |  
  |asset_definition_url|The url of asset definition file.|

* **get_balance**  
Returns the balance in both bitcoin and colored coin assets for all of the addresses available in your Bitcoin Core wallet.
  ```ruby
  # get all balance in the wallet.
  api.get_balance
  
  # specify the open asset address.
  api.get_balance('akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6')
  > [
      {
        "address": "1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG",
        "oa_address": "akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6",
        "value": "0.00018200",
        "assets": [
          {
            "asset_id": "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
            "quantity": "81",
            "amount": "20.7",
            "asset_definition_url": "http://goo.gl/fS4mEj"
          },
          {
            "asset_id": "AJk2Gx5V67S2wNuwTK5hef3TpHunfbjcmX",
            "quantity": "67",
            "amount": "6.7",
            "asset_definition_url": ""
          }
        ],
        "account": "openassets-ruby"
      },
  ``` 
  Output items are as follows.
  
  |Item|description|
  |:---|:---|
  |address| A P2PKH or P2SH address.|
  |oa_address|The Open Asset address.|
  |value|The Bitcoin amount.|
  |assets|The array of the assets.|
  |asset_id|The asset ID is a 160 bits hash, used to uniquely identify the asset stored on the output.|
  |asset_quantity|The asset quantity is an unsigned integer representing how many units of that asset are stored on the output.|
  |asset_amount| The asset amount is the value obtained by converting the asset quantity to the unit of divisibility that are defined in the Asset definition file. |  
  |asset_definition_url|The url of asset definition file.|
  |account|The name of an account.|
  
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
  # api.send_asset(<from open asset address>, <asset ID>, <asset quantity>, <to open asset address>, <fees (The fess in satoshis for the transaction. use 10000 satoshi if specified nil)>, <mode=('broadcast', 'signed', 'unsigned')>, <output_qty default value is 1.>)

  # example
  from = 'akXDPMMHHBrUrd1fM756M1GSB8viVAwMyBk'
  to = 'akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6'
  api.send_asset(from, 'AWo3R89p5REmoSyMWB8AeUmud8456bRxZL', 100, to, 10000, 'broadcast')
  ``` 
If specified ``output_qty``, the send output is divided by the number of output_qty.   
Ex, asset holding amount = 200, and send  amount = 125 and output_qty = 2, the marker output asset quantity is [62, 63, 75] and send TxOut is three. The last of the asset quantity is change asset output.
  
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

* **get_outputs_from_txid**  
Get tx outputs. (use for debug)
  ```ruby
  api.get_outputs_from_txid('3fba8bfb157ae29c293d5bd65c178fec169a87f880e2e62537fcce26612a6aa3')
  > [{
      "address": "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
      "oa_address": "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
      "script": "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
      "amount": "0.00000600",
      "asset_id": "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
      "asset_quantity": "1",
      "asset_amount": "1",
      "account": null,
      "asset_definition_url": "",
      "txid": "3fba8bfb157ae29c293d5bd65c178fec169a87f880e2e62537fcce26612a6aa3",
      "vout": 1
    },..
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
