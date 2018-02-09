require 'spec_helper'

describe Instrumentality::Profile::Custom do
  context 'initialized with all available flags' do
    let(:params) do
      OpenStruct.new({'script' => 'custom.d',
                      'process' => 'Instr',
                      'workspace' => 'Instr.xcworkspace',
                      'project' => '',
                      'scheme' => 'Instr',
                      'server_port' => '9091',
                      'interactive' => true,
                      'experimental' => false})
    end

    before do
      allow_any_instance_of(Instrumentality::Profiler).to receive(:profile)
      argv = CLAide::ARGV.new(%W[Instr custom.d --workspace=#{params.workspace} --project=#{params.params} --scheme=#{params.scheme} --server-port=#{params.server_port} --interactive --verbose])
      @subject = Instrumentality::Profile::Custom.new(argv)
    end

    it 'should pass all parameters to Instrumentality::Profiler' do
      profiler = instance_double("Instrumentality::Profiler")
      profiler_class = class_double("Instrumentality::Profiler").as_stubbed_const
      expect(profiler_class).to receive(:new).with(params, true).and_return(profiler)
      expect(profiler).to receive(:profile)
      @subject.run
    end
  end
end
