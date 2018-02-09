require "spec_helper"

describe Instrumentality::Benchmark do
  context 'initialized without a target process name' do
    before do
      argv = CLAide::ARGV.new(%w[])
      @subject = Instrumentality::Benchmark.new(argv)
    end

    it 'should raise an error' do
      expect do
        @subject.validate!
      end.to raise_error(CLAide::Help)
    end
  end

  context 'initialized with a target process name on empty directory' do
    before do
      argv = CLAide::ARGV.new(%w[instr])
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          @subject = Instrumentality::Benchmark.new(argv)
        end
      end
    end

    it "should raise an error when can't find workspace or project files" do
      expect do
        @subject.validate!
      end.to raise_error(CLAide::Help)
    end
  end

  context 'initialzied with a target process name on empty directory with interactive mode enabled' do
    before do
      argv = CLAide::ARGV.new(%w[instr --interactive])
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          @subject = Instrumentality::Benchmark.new(argv)
        end
      end
    end

    it 'should nto raise an error when interactive mode is enabled' do
      expect do
        @subject.validate!
      end.not_to raise_error
    end
  end

  context 'initialized with a target process on directory with xcworkspace' do
    before do
      argv = CLAide::ARGV.new(%w[instr])
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          File.new("Test.xcworkspace", "w")
          @subject = Instrumentality::Benchmark.new(argv)
        end
      end
    end

    it "s hould raise an error when can't find workspace or project files" do
      expect do
        @subject.validate!
      end.not_to raise_error
    end
  end

  context 'initialized with a target process on directory with xcodeproj' do
    before do
      argv = CLAide::ARGV.new(%w[instr])
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          File.new("Test.xcodeproj", "w")
          @subject = Instrumentality::Benchmark.new(argv)
        end
      end
    end

    it "s hould raise an error when can't find workspace or project files" do
      expect do
        @subject.validate!
      end.not_to raise_error
    end
  end
end
