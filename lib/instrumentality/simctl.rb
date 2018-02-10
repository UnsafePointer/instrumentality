require 'instrumentality/constants'
require 'simctl'

module Instrumentality
  class Simctl
    def self.execute_with_simulator_ready(runtime, type)
      device = create_device(runtime, type)
      device.launch
      device.wait(Constants::TIMEOUT) do |d|
        d.state == :booted && d.ready?
      end
      begin
        yield device
      rescue StandardError => error
        throw error
      ensure
        delete_device(device.uuid)
      end
    end

    def self.create_device(runtime, type)
      runtime = if runtime.eql? 'latest'
                  SimCtl::Runtime.latest('ios')
                else
                  SimCtl.runtime(name: runtime)
                end
      device_type = SimCtl.devicetype(name: type)
      device_name = "#{type}-instr"
      SimCtl.reset_device(device_name, device_type, runtime)
    end

    private_class_method :create_device

    def self.delete_device(device)
      if device.state != :shutdown
        device.shutdown
        device.kill
        device.wait do |d|
          d.state == :shutdown
        end
      end
      device.delete
    end

    private_class_method :delete_device
  end
end
