require 'spec_helper'

describe Instrumentality::Finder do
  describe '.find_workspace' do
    context 'when there is a workspace file' do
      let(:file_path) { "./Test.xcworkspace" }
      it 'should find the file' do
        Dir.mktmpdir do |tmpdir|
          Dir.chdir(tmpdir) do
            File.new(file_path, "w")
            expect(Instrumentality::Finder.find_workspace).to eql(file_path)
          end
        end
      end
    end

    context('when there is a workspace file with depth 2') do
      let(:dir_name) { "Test" }
      let(:file_path) { "./#{dir_name}/Test.xcworkspace" }
      it 'should find the file' do
        Dir.mktmpdir do |tmpdir|
          Dir.chdir(tmpdir) do
            Dir.mkdir(dir_name)
            File.new(file_path, "w")
            expect(Instrumentality::Finder.find_workspace).to eql(file_path)
          end
        end
      end
    end
  end

  describe '.find_project' do
    context 'when there is a project file' do
      let(:file_path) { "./Test.xcodeproj" }
      it 'should find the file' do
        Dir.mktmpdir do |tmpdir|
          Dir.chdir(tmpdir) do
            File.new(file_path, "w")
            expect(Instrumentality::Finder.find_project).to eql(file_path)
          end
        end
      end
    end

    context('when there is a project file with depth 2') do
      let(:dir_name) { "Test" }
      let(:file_path) { "./#{dir_name}/Test.xcodeproj" }
      it 'should find the file' do
        Dir.mktmpdir do |tmpdir|
          Dir.chdir(tmpdir) do
            Dir.mkdir(dir_name)
            File.new(file_path, "w")
            expect(Instrumentality::Finder.find_project).to eql(file_path)
          end
        end
      end
    end
  end

  describe '.find_xctestrun' do
    context 'when there is a xctestrun file' do
      let(:file_path) { "./Test.xctestrun" }
      it 'should find the file' do
        Dir.mktmpdir do |tmpdir|
          Dir.chdir(tmpdir) do
            File.new(file_path, "w")
            expect(Instrumentality::Finder.find_xctestrun('.')).to eql(file_path)
          end
        end
      end
    end
  end

  describe '.path_for_script' do
    context 'when there is a script file' do
      let(:script_name) { "Test.d" }
      it 'should find the file' do
        Dir.mktmpdir do |tmpdir|
          Dir.chdir(tmpdir) do
            File.new(script_name, "w")
            expect(Instrumentality::Finder.path_for_script(script_name)).to eql(script_name)
          end
        end
      end
    end

    context "when there isn't a script file" do
      let(:existing_script_name) { "benchmark.d" }
      let(:existing_script_path) { File.expand_path("../../lib/instrumentality/scripts/#{existing_script_name}", __FILE__) }
      it 'should fallback to existing scripts' do
        expect(Instrumentality::Finder.path_for_script(existing_script_name)).to eql(existing_script_path)
      end
    end
  end

  describe '.path_for_header' do
    context 'when there is a header file' do
      let(:existing_header_name) { "benchmark.d" }
      let(:existing_header_path) { File.expand_path("../../lib/instrumentality/headers/#{existing_header_name}", __FILE__) }
      it 'should fallback to existing scripts' do
        expect(Instrumentality::Finder.path_for_header(existing_header_name)).to eql(existing_header_path)
      end
    end
  end
end
