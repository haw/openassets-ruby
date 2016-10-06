require 'spec_helper'

describe OpenAssets::Protocol::AssetDefinitionLoader, :network => :testnet do

  describe 'initialize' do

    context 'http or https' do
      subject{
        OpenAssets::Protocol::AssetDefinitionLoader.new('http://goo.gl/fS4mEj').loader
      }
      it do
        expect(subject).to be_a(OpenAssets::Protocol::HttpAssetDefinitionLoader)
      end
    end

    context 'invalid scheme' do
      subject{
        OpenAssets::Protocol::AssetDefinitionLoader.new('<http://www.caiselian.com>')
      }
      it do
        expect(subject.load_definition).to be_nil
      end
    end

  end

  describe 'create_pointer_redeem_script' do
    subject {
      OpenAssets::Protocol::AssetDefinitionLoader.create_pointer_redeem_script('https://goo.gl/bmVEuw', 'bWwvzRQ6Lux9rWgeqTe91XwbxvFuxzK56cx')
    }
    it do
      expect(subject.chunks[0]).to eq('u=https://goo.gl/bmVEuw')
      expect(subject.chunks[1]).to eq(Bitcoin::Script::OP_DROP)
      expect(subject.chunks[2]).to eq(Bitcoin::Script::OP_DUP)
      expect(subject.chunks[3]).to eq(Bitcoin::Script::OP_HASH160)
      expect(subject.chunks[4]).to eq('46c2fbfbecc99a63148fa076de58cf29b0bcf0b0'.htb) # bWwvzRQ6Lux9rWgeqTe91XwbxvFuxzK56cx のBitcoinアドレスのhash160
      expect(subject.chunks[5]).to eq(Bitcoin::Script::OP_EQUALVERIFY)
      expect(subject.chunks[6]).to eq(Bitcoin::Script::OP_CHECKSIG)
    end
  end

  describe 'create_pointer_p2sh' do
    subject {
      OpenAssets::Protocol::AssetDefinitionLoader.create_pointer_p2sh('https://goo.gl/bmVEuw', 'bWwvzRQ6Lux9rWgeqTe91XwbxvFuxzK56cx')
    }
    it do
      expect(subject.is_p2sh?).to be true
      redeem_script = OpenAssets::Protocol::AssetDefinitionLoader.create_pointer_redeem_script('https://goo.gl/bmVEuw', 'bWwvzRQ6Lux9rWgeqTe91XwbxvFuxzK56cx')
      expect(subject.chunks[1]).to eq(Bitcoin.hash160(redeem_script.to_payload.bth).htb)
    end
  end

  describe 'redeem pointer p2sh' do
    it do
      issuance_tx = Bitcoin::Protocol::Tx.new('01000000010ae08e10dad8548a6e5eef11c5ff76f77ba865f186f6247d3d9502a59c37b588020000006b483045022100fc0d5caa16f3c21939a87b7724dca14c54b1be6a27b253bd1087009ec3873000022062a9b9e40028797526668cb07f91001f3d098461f0a610bd05db7888caac378a01210292ee82d9add0512294723f2c363aee24efdeb3f258cdaf5118a4fcf5263e92c9ffffffff03580200000000000017a914c590a1c93975aec75157e33ad904a74d2934e9d58700000000000000000b6a094f41010001d0860300f8d90000000000001976a91446c2fbfbecc99a63148fa076de58cf29b0bcf0b088ac00000000'.htb)
      tx = Bitcoin::Protocol::Tx.new
      tx.add_in(Bitcoin::Protocol::TxIn.from_hex_hash(issuance_tx.hash, 0))
      tx.add_out(Bitcoin::Protocol::TxOut.value_to_address(100, 'mmy7BEH1SUGAeSVUR22pt5hPaejo2645F1'))

      key = Bitcoin::Key.from_base58('cPaJYBMDLjQp5gSUHnBfhX4Rgj95ekBS6oBttwQLw3qfsKKcDfuB')
      def_url = 'https://goo.gl/bmVEuw'
      to = 'bWwvzRQ6Lux9rWgeqTe91XwbxvFuxzK56cx'

      redeem_script = OpenAssets::Protocol::AssetDefinitionLoader.create_pointer_redeem_script(def_url, to)
      sig_hash = tx.signature_hash_for_input(0, redeem_script.to_payload, Bitcoin::Script::SIGHASH_TYPE[:all])
      sig = Bitcoin::Script.to_pubkey_script_sig(key.sign(sig_hash), key.pub.htb)
      script_sig = Bitcoin::Script.new(sig + Bitcoin::Script.pack_pushdata(redeem_script.to_payload))

      tx.in[0].script_sig = script_sig.to_payload
      expect(tx.verify_input_signature(0, issuance_tx)).to be true
    end
  end

end