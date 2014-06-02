require 'puppet/indirector/revision'
require 'puppet/indirector/rest'

class Puppet::Indirector::Revision::Rest < Puppet::Indirector::REST

  desc "Get puppet master's revision (config_version) via REST"

end
