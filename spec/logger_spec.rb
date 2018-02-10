require 'spec_helper'

describe Instrumentality::Logger do
  describe '.log' do
    let(:prefix) { Instrumentality::Constants::OUTPUT_PREFIX }
    let(:message) { "HAI DOMO, KIZUNA AI DESU" }
    it 'should output content with prefix' do
      expect do
        Instrumentality::Logger.log(message)
      end.to output("#{prefix} #{message}\n").to_stdout
    end
  end
end
