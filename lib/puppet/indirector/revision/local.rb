require 'puppet/indirector/revision'

class Puppet::Indirector::Revision::Local < Puppet::Indirector::Code

  desc "Get revision locally. Only used internally."

  def find( *anything )
    Puppet.settings.preferred_run_mode= :master
    config_version = Puppet.settings[:config_version]
    return nil if config_version.empty?
    begin
      Puppet::Util::Execution.execute([config_version]).strip
    rescue
    end
  end
end

