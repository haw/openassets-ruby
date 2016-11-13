require 'spec_helper'

describe 'Segwit Support', :network => :testnet do

  describe 'api' do

    describe 'get_tx' do
      context 'P2WPKH nested in P2SH' do
        subject{
          # witness tx
          Bitcoin::Protocol::Tx.new('020000000001036c99ba51936407ffc8bdc27a5e1bbc824901a98fbe177a990d0ad0bf07ba71db01000000171600142b2f993ce6242905bced779c64e1518d7fa9fca9ffffffffe08e6691b4199e49025b0a22001dbdc4d84dca51b1477b62638722c018eaf07900000000171600142b2f993ce6242905bced779c64e1518d7fa9fca9ffffffffdc935aae5ffafc0d962d3897d795a5c66daee2bc62ec19677096a75f6fad616101000000171600142b2f993ce6242905bced779c64e1518d7fa9fca9ffffffff0200943577000000001600141e205151c90c16475363d11b7b8c235cf6c7d695f6c79a3b0000000016001479bd8ae9a7c93f95b462c66107aeef6de849315c024730440220672bf4958c39c3e588d68b29cd8ac0377f627fbfcfa457655e06889f9b84439802202d62dd45fa074c312ccd9e1719a1f7bb9040e934fbec9541fae3fb4eed55af28012103f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa02483045022100ef1ab82a7311ab86deab033d95037bf9a3e5b1e35492b329bd79f5ac15b9c6a00220186842e44b043d37f2489e2b88a0a7fc800182fb015168877af68ae35f54eb8b012103f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa02473044022000f5e8c01991669897df4830c904d5cb28650eddfb1d07e1bb92935f6f9c2f71022005c7d8a80148c9025b9df7392f841d2c36bc18e5013b15895bf4ca166eb113ab012103f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa00000000'.htb)
        }
        it do
          expect(subject.hash).to eq('d8d1274dbf7737bfcd81b608a62ea7a091df01439f4265ac8476bcad03fd1603')
          expect(subject.witness_hash).to eq('cc51b643be605f22756af874c552894b969e999318ce98527dbc6144a6a9c910')
          expect(subject.in.length).to eq(3)
          expect(subject.out.length).to eq(2)
          expect(subject.witness.tx_in_wit.length).to eq(3)
          expect(subject.witness.tx_in_wit[0].stack.length).to eq (2)
          expect(subject.witness.tx_in_wit[0].stack[0]).to eq('30440220672bf4958c39c3e588d68b29cd8ac0377f627fbfcfa457655e06889f9b84439802202d62dd45fa074c312ccd9e1719a1f7bb9040e934fbec9541fae3fb4eed55af2801')
          expect(subject.witness.tx_in_wit[0].stack[1]).to eq('03f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa')
          expect(subject.witness.tx_in_wit[1].stack[0]).to eq('3045022100ef1ab82a7311ab86deab033d95037bf9a3e5b1e35492b329bd79f5ac15b9c6a00220186842e44b043d37f2489e2b88a0a7fc800182fb015168877af68ae35f54eb8b01')
          expect(subject.witness.tx_in_wit[1].stack[1]).to eq('03f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa')
          expect(subject.witness.tx_in_wit[2].stack[0]).to eq('3044022000f5e8c01991669897df4830c904d5cb28650eddfb1d07e1bb92935f6f9c2f71022005c7d8a80148c9025b9df7392f841d2c36bc18e5013b15895bf4ca166eb113ab01')
          expect(subject.witness.tx_in_wit[2].stack[1]).to eq('03f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa')
        end
      end

      context 'P2WPKH' do

      end
    end

  end

end