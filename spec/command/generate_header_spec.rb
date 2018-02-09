require 'spec_helper'

describe Instrumentality::GenerateHeader do
  context 'initialized without an instrument name' do
    before do
      argv = CLAide::ARGV.new(%w[])
      @subject = Instrumentality::GenerateHeader.new(argv)
    end

    it 'should raise an error' do
      expect do
        @subject.validate!
      end.to raise_error(CLAide::Help)
    end
  end

  context 'initialized with an instrument name' do
    let(:params) do
      'benchmark'
    end

    before do
      argv = CLAide::ARGV.new(%W[#{params} --verbose])
      @subject = Instrumentality::GenerateHeader.new(argv)
    end

    it 'should not raise an error' do
      expect do
        @subject.validate!
      end.not_to raise_error(CLAide::Help)
    end

    it 'should pass all parameters to Instrumentality::HeaderGenerator' do
      profiler = instance_double("Instrumentality::HeaderGenerator")
      profiler_class = class_double("Instrumentality::HeaderGenerator").as_stubbed_const
      expect(profiler_class).to receive(:new).with(params, true).and_return(profiler)
      expect(profiler).to receive(:generate)
      @subject.run
    end
  end
end
