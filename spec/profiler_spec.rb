require 'spec_helper'

describe Instrumentality::Profiler do
  describe '.initialize' do
    context "with a script that doesn't support experimental flag" do
      let(:config) do
        OpenStruct.new({'script' => 'do_not_support.d',
                        'experimental' => true})
      end

      it('should raise an error') do
        expect do
          Instrumentality::Profiler.new(config)
        end.to raise_error(Instrumentality::Profiler::ProfilerError)
      end
    end

    context 'with a script that supports experimental flag' do
      let(:config) do
        OpenStruct.new({'script' => 'file_activity.d',
                        'experimental' => true})
      end

      it('should not raise an error') do
        expect do
          Instrumentality::Profiler.new(config)
        end.not_to raise_error
      end
    end
  end

  describe '.profile' do
    let(:process) { 'instr' }
    let(:script) { Instrumentality::Constants::BENCHMARK_SCRIPT }
    let(:script_path) { Instrumentality::Finder.path_for_script(script) }
    let(:pid) { '1' }
    let(:dtrace_attach_cmd) { "sudo dtrace -q -s #{script_path} -p #{pid}" }

    context "without interactive flag" do
      let(:workspace) { 'Instr.xcworkspace' }
      let(:scheme) { 'Instr' }
      let(:build_for_testing_cmd) { "xcodebuild -workspace #{Dir.pwd}/#{workspace} -scheme #{scheme} -sdk iphonesimulator" }
      let(:default_runtime) { Instrumentality::Constants::DEFAULT_RUNTIME }
      let(:default_device_type) { Instrumentality::Constants::DEFAULT_DEVICE }
      let(:device_uuid) { 'ABCDE' }
      let(:test_without_building_cmd) { "xcodebuild -xctestrun" }
      let(:test_destination) { "-destination 'platform=iOS Simulator,id=#{device_uuid}'" }
      let(:xcodebuild_pid) { '2' }
      let(:dtrace_pid) { '3' }
      let(:server_port) { 9091 }
      let(:config) do
        OpenStruct.new({'script' => script,
                        'process' => process,
                        'workspace' => workspace,
                        'project' => nil,
                        'scheme' => scheme,
                        'server_port' => server_port.to_s,
                        'interactive' => false,
                        'experimental' => false})
      end

      before do
        @subject = Instrumentality::Profiler.new(config)
      end

      it('should compile, run tests and attach dtrace ') do
        expect(Instrumentality::Executor).to receive(:execute).exactly(1) do |cmd|
          expect(cmd).to start_with(build_for_testing_cmd)
          expect(cmd).to include('clean build-for-testing')
        end
        expect(Instrumentality::Simctl).to receive(:execute_with_simulator_ready).exactly(1) do |runtime, device_type|
          expect(runtime).to eql(default_runtime)
          expect(device_type).to eql(default_device_type)
        end.and_yield(device_uuid)
        expect(Instrumentality::Executor).to receive(:execute_async).exactly(1) do |cmd|
          expect(cmd).to start_with(test_without_building_cmd)
          expect(cmd).to include(test_destination)
          expect(cmd).to include('test-without-building')
        end.and_return(xcodebuild_pid)
        expect(Instrumentality::Executor).to receive(:timeout).exactly(1) do |param|
          expect(param).to eql(process)
        end.and_return(pid)
        http = instance_double("Net::HTTP")
        expect(Net::HTTP).to receive(:new).exactly(1) do |host, port|
          expect(host).to eql('localhost')
          expect(port).to eql(server_port)
        end.and_return(http)
        expect(http).to receive(:request)
        expect(Instrumentality::Executor).to receive(:execute_async).exactly(1) do |cmd|
          expect(cmd).to start_with(dtrace_attach_cmd)
        end.and_return(dtrace_pid)
        expect(Process).to receive(:wait).exactly(1) do |pid|
          expect(pid).to eql(xcodebuild_pid)
        end
        expect(Process).to receive(:kill).exactly(1) do |signal, pid|
          expect("QUIT").to eql(signal)
          expect(pid).to eql(dtrace_pid)
        end
        expect(@subject).to receive(:process_dtrace_output).exactly(1)
        @subject.profile
      end
    end

    context "with interactive flag" do
      let(:config) do
        OpenStruct.new({'script' => script,
                        'process' => process,
                        'workspace' => 'Instr.xcworkspace',
                        'project' => nil,
                        'scheme' => 'Instr',
                        'server_port' => '9091',
                        'interactive' => true,
                        'experimental' => false})
      end

      before do
        @subject = Instrumentality::Profiler.new(config)
      end

      it('should attach dtrace') do
        expect(Instrumentality::Executor).to receive(:timeout).exactly(1) do |param|
          expect(param).to eql(process)
        end.and_return(pid)
        expect(Instrumentality::Executor).to receive(:execute_async).exactly(1) do |cmd|
          expect(cmd).to start_with(dtrace_attach_cmd)
        end
        expect(@subject).to receive(:stream_dtrace_output).exactly(1)
        @subject.profile
      end
    end
  end
end
