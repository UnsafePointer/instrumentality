require 'spec_helper'

describe Instrumentality::Executor do
  before do
    allow(Instrumentality::Logger).to receive(:log)
  end

  describe '.execute' do
    context 'when command exits with status different than zero' do
      let(:command) { 'exit 1' }

      it 'should raise an error' do
        expect do
          Instrumentality::Executor.execute(command)
        end.to raise_error(Instrumentality::Executor::ExecutorError)
      end
    end

    context 'when command exits with status zero' do
      let(:command) { 'echo "Hi!"' }

      it 'should not raise an error' do
        expect do
          Instrumentality::Executor.execute(command)
        end.not_to raise_error
      end
    end
  end

  describe '.execute_async' do
    let(:command) { 'sleep 5' }

    it 'should spawn process' do
      expect(Process).to receive(:spawn).exactly(1) do |cmd|
        expect(cmd).to eql(command)
      end
      Instrumentality::Executor.execute_async(command)
    end
  end

  describe '.timeout' do
    context "when process doesn't exist" do
      let(:process) { 'most_certainly_does_not_exist_dot_exe' }
      let(:timeout) { 1 }

      it 'should raise an error' do
        expect do
          Instrumentality::Executor.timeout(process, timeout)
        end.to raise_error(Instrumentality::Executor::ExecutorError)
      end
    end

    context 'when process exist' do
      let(:process) { 'Finder' }
      let(:timeout) { 1 }

      it 'should return a pid' do
        expect(Instrumentality::Executor.timeout(process, timeout)).not_to eql('')
      end
    end
  end
end
