require 'spec_helper'

describe 'Segwit Support', :network => :testnet do

  describe 'api' do

    describe 'get_tx' do

      context 'P2WPKH nested in P2SH' do
        subject{
          Bitcoin::Protocol::Tx.new('020000000001036c99ba51936407ffc8bdc27a5e1bbc824901a98fbe177a990d0ad0bf07ba71db01000000171600142b2f993ce6242905bced779c64e1518d7fa9fca9ffffffffe08e6691b4199e49025b0a22001dbdc4d84dca51b1477b62638722c018eaf07900000000171600142b2f993ce6242905bced779c64e1518d7fa9fca9ffffffffdc935aae5ffafc0d962d3897d795a5c66daee2bc62ec19677096a75f6fad616101000000171600142b2f993ce6242905bced779c64e1518d7fa9fca9ffffffff0200943577000000001600141e205151c90c16475363d11b7b8c235cf6c7d695f6c79a3b0000000016001479bd8ae9a7c93f95b462c66107aeef6de849315c024730440220672bf4958c39c3e588d68b29cd8ac0377f627fbfcfa457655e06889f9b84439802202d62dd45fa074c312ccd9e1719a1f7bb9040e934fbec9541fae3fb4eed55af28012103f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa02483045022100ef1ab82a7311ab86deab033d95037bf9a3e5b1e35492b329bd79f5ac15b9c6a00220186842e44b043d37f2489e2b88a0a7fc800182fb015168877af68ae35f54eb8b012103f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa02473044022000f5e8c01991669897df4830c904d5cb28650eddfb1d07e1bb92935f6f9c2f71022005c7d8a80148c9025b9df7392f841d2c36bc18e5013b15895bf4ca166eb113ab012103f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa00000000'.htb)
        }
        it do
          expect(subject.hash).to eq('d8d1274dbf7737bfcd81b608a62ea7a091df01439f4265ac8476bcad03fd1603')
          expect(subject.witness_hash).to eq('cc51b643be605f22756af874c552894b969e999318ce98527dbc6144a6a9c910')
          expect(subject.in.length).to eq(3)
          expect(subject.out.length).to eq(2)
          expect(subject.in[0].script_sig.bth).to eq('1600142b2f993ce6242905bced779c64e1518d7fa9fca9')
          expect(subject.witness.tx_in_wit.length).to eq(3)
          expect(subject.witness.tx_in_wit[0].stack.length).to eq (2)
          expect(subject.witness.tx_in_wit[0].stack[0]).to eq('30440220672bf4958c39c3e588d68b29cd8ac0377f627fbfcfa457655e06889f9b84439802202d62dd45fa074c312ccd9e1719a1f7bb9040e934fbec9541fae3fb4eed55af2801')
          expect(subject.witness.tx_in_wit[0].stack[1]).to eq('03f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa')
          expect(subject.witness.tx_in_wit[1].stack[0]).to eq('3045022100ef1ab82a7311ab86deab033d95037bf9a3e5b1e35492b329bd79f5ac15b9c6a00220186842e44b043d37f2489e2b88a0a7fc800182fb015168877af68ae35f54eb8b01')
          expect(subject.witness.tx_in_wit[1].stack[1]).to eq('03f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa')
          expect(subject.witness.tx_in_wit[2].stack[0]).to eq('3044022000f5e8c01991669897df4830c904d5cb28650eddfb1d07e1bb92935f6f9c2f71022005c7d8a80148c9025b9df7392f841d2c36bc18e5013b15895bf4ca166eb113ab01')
          expect(subject.witness.tx_in_wit[2].stack[1]).to eq('03f9affd1cabc1e4acabd07128b932fba2126866321bf3a98653761f28ed958ffa')
          expect(subject.out[0].parsed_script.to_payload.bth).to eq('00141e205151c90c16475363d11b7b8c235cf6c7d695')
          expect(subject.out[0].parsed_script.get_address).to be_nil
          expect(subject.out[0].parsed_script.is_standard?).to be true
          expect(subject.out[0].parsed_script.is_witness_v0_keyhash?).to be true
          expect(subject.out[0].parsed_script.type).to eq(:witness_v0_keyhash)
          expect(subject.out[1].parsed_script.to_payload.bth).to eq('001479bd8ae9a7c93f95b462c66107aeef6de849315c')
          expect(subject.out[1].parsed_script.get_address).to be_nil
        end
      end

      context 'P2WPKH' do
        subject{
          Bitcoin::Protocol::Tx.new('02000000000101bd8845c435b23c5211ce66f88b7fdc9c1f6f398982d958dea26f2f5bcd74a5af0600000000ffffffff0ba086010000000000160014d702116d39b3e09e9e470ffbdacb8b37585ae0cda086010000000000160014d493052ed9b65cc64b48929c6c7d9cf3511d305ea086010000000000160014ba6d07e9673f1de012e485272b56eac8fd946b14a086010000000000160014d03c27e774f0e5001111e8f15057373a5955d9afa08601000000000016001492ee96db74d42c782e76934eb6bb540304d3a1cca0860100000000001600143b4be4abc0ccaa1aaba16798c73cdcff9b8693f8a08601000000000016001490b3985459e7dd82f61291664b9c0240c7a8862ca0860100000000001600144f7d64ee9de267e6dcf1da9a486c7a59e12a89aba086010000000000160014fbaa036f8fceda60dcef1cdf0c35445030e2730f941b4a140100000016001495e62aaa26435362b271eebc9ce3cb82b286ecc9a086010000000000160014bbd4cf49fa3131169159289e2e3b6e851d23f9d402473044022042663b93c21eaef25e085104972bf23353fcc6d6d7b16cfd763dd42b67c0647c0220043b41da107479f121338a7168b0dcc6a1c5342824c7f21b4e158b4a4342ba8b01210276a5322440576e15d4291bb86a966124b9ceaa636e77dd0e8de846e5b7ab4f8c00000000'.htb)
        }
        it do
          expect(subject.hash).to eq('f22f5168cf0bc55a31003b0fc532152da551e1ec4289c4fd92e7ec512c6e87a0')
          expect(subject.witness_hash).to eq('c9609ed4d7e60ebcf4cce2854568b54a855a12b5bda15433ca96e72cd445a5cf')
          expect(subject.in.length).to eq(1)
          expect(subject.out.length).to eq(11)
          expect(subject.witness.tx_in_wit.length).to eq(1)
          expect(subject.witness.tx_in_wit[0].stack.length).to eq (2)
          expect(subject.witness.tx_in_wit[0].stack[0]).to eq('3044022042663b93c21eaef25e085104972bf23353fcc6d6d7b16cfd763dd42b67c0647c0220043b41da107479f121338a7168b0dcc6a1c5342824c7f21b4e158b4a4342ba8b01')
          expect(subject.witness.tx_in_wit[0].stack[1]).to eq('0276a5322440576e15d4291bb86a966124b9ceaa636e77dd0e8de846e5b7ab4f8c')
          expect(subject.in[0].script_length).to eq(0)
          expect(subject.in[0].script_sig.bth).to eq('')
        end
      end

    end

  end

end