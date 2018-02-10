require 'spec_helper'

describe Instrumentality::HeaderGenerator do
  describe '#generate' do
    context "when a header doesn't exist" do
      let(:instrument) { 'this_does_not_exist' }
      before do
        @subject = Instrumentality::HeaderGenerator.new(instrument)
      end

      it 'should raise an error' do
        expect do
          @subject.generate
        end.to raise_error(Instrumentality::HeaderGenerator::HeaderGeneratorError)
      end
    end

    context 'when a header exist' do
      let(:instrument) { 'benchmark' }
      let(:instrument_header_path) { File.expand_path("../../lib/instrumentality/headers/#{instrument}.d", __FILE__) }
      let(:params) { "dtrace -h -s #{instrument_header_path}" }
      before do
        @subject = Instrumentality::HeaderGenerator.new(instrument)
      end

      it 'should not raise an error' do
        executor_class = class_double("Instrumentality::Executor").as_stubbed_const
        expect(executor_class).to receive(:execute).with(params, false)
        @subject.generate
      end
    end
  end
end
