require 'spec_helper'

describe Bitcoin::Script do

  describe 'witness_v0_keyhash' do
    subject {
      Bitcoin::Script.new('00141e205151c90c16475363d11b7b8c235cf6c7d695'.htb)
    }
    it do
      expect(subject.is_standard?).to be true
      expect(subject.is_witness_v0_keyhash?).to be true
      expect(subject.is_witness_v0_scripthash?).to be false
      expect(subject.type).to eq(:witness_v0_keyhash)
    end
  end

  describe 'witness_v0_scripthash' do
    subject{
      Bitcoin::Script.new('00205d1b56b63d714eebe542309525f484b7e9d6f686b3781b6f61ef925d66d6f6a0'.htb)
    }
    it do
      expect(subject.is_standard?).to be true
      expect(subject.is_witness_v0_keyhash?).to be false
      expect(subject.is_witness_v0_scripthash?).to be true
      expect(subject.type).to eq(:witness_v0_scripthash)
    end
  end

end