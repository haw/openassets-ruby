require 'spec_helper'

describe OpenAssets::Transaction::SpendableOutput, :network => :testnet do

  it 'to hash' do
    issue_spec = Bitcoin::Protocol::Tx.new('010000000154f5a67cb14d7e50056f53263b72165daaf438164e7e825b862b9062a4e40612000000006b48304502210098e16e338e9600876e30d9dc0894bcd1bbb612431e7a36732c5feab0686d0641022044e7dcd512073f31d0c67e0fbbf2269c4a31d5bf3bb1fcc8fbdd2e4d3c0d7e58012103e46fdcbf2062598a221c0e34d0505c270fb77c2c305c40ef0919f8efc0c7f959ffffffff0358020000000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac0000000000000000216a1f4f410100018f4e17753d68747470733a2f2f676f6f2e676c2f755667737434b8770700000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac00000000'.htb)
    transfer_spec = Bitcoin::Protocol::Tx.new('0100000002dd6cee22d848a609df2d316112ca26b569c97c189400ad6f01046d65aa7b5f52000000006a473044022021806c9f0d888862cb6e8eb3952c48499fe4c0bedc4fb3ef20743c418109a23b02206249fceeeb4c2f496a3a48b57087f97e540af465f8b9328919f6f536ba5346ed012103e46fdcbf2062598a221c0e34d0505c270fb77c2c305c40ef0919f8efc0c7f959ffffffffdd6cee22d848a609df2d316112ca26b569c97c189400ad6f01046d65aa7b5f52020000006b483045022100981c9757ddf1280a47e9274fae9ff331a1a5b750c7f0c2a18de0b18413a3121e0220395d8baeb7802f9f3947152098442144946987d6be4065a0febe20bc20ca55df012103e46fdcbf2062598a221c0e34d0505c270fb77c2c305c40ef0919f8efc0c7f959ffffffff0400000000000000000b6a094f4101000263ac4d0058020000000000001976a914e9ac589641f17a2286631c24d6d2d00b8c959eb588ac58020000000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac504e0700000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac00000000'.htb)
    metadata = OpenAssets::Protocol::MarkerOutput.deserialize_payload(
        OpenAssets::Protocol::MarkerOutput.parse_script(issue_spec.outputs[1].parsed_script.to_payload)).metadata
    output = OpenAssets::Protocol::TransactionOutput.new(
        600, transfer_spec.outputs[2].parsed_script, 'oK31ByjFuNhfnFuRMmZgchsdiprYmRzuz5', 9900, OpenAssets::Protocol::OutputType::TRANSFER, metadata)
    output.account = ''
    result = OpenAssets::Transaction::SpendableOutput.new(
        OpenAssets::Transaction::OutPoint.new('2ef6aaf051229ff755a137a51466b54da6d8c87d17130bca8a879e9e64172ebd', 2), output)
    result.confirmations = 20842
    expect(result.to_hash).to match(
                                  'txid' => '2ef6aaf051229ff755a137a51466b54da6d8c87d17130bca8a879e9e64172ebd',
                                  'vout' => 2,
                                  'address' => 'mkgW6hNYBctmqDtTTsTJrsf2Gh2NPtoCU4',
                                  'oa_address' => 'bWvePLsBsf6nThU3pWVZVWjZbcJCYQxHCpE',
                                  'script' => '76a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac',
                                  'script_type' => 'pubkeyhash',
                                  'amount' => '0.00000600',
                                  'confirmations' => 20842,
                                  'asset_id' => 'oK31ByjFuNhfnFuRMmZgchsdiprYmRzuz5',
                                  'account' => '',
                                  'asset_quantity' => '9900',
                                  'asset_amount' => '990.0',
                                  'asset_definition_url' => 'https://goo.gl/uVgst4',
                                  'proof_of_authenticity' => false,
                                  'output_type' => 'transfer')
  end

end