require 'puppet/face'
require 'puppet/revision'

Puppet::Face.define(:sockpuppet, '0.0.1') do
  copyright "Puppet Labs", 2011
  license   "Apache 2 license; see COPYING"

  summary "Applies the latest catalog, requesting from the Master if needed."
  description <<-'EOT'
    This face will request the Master's codebase revision and calculate a hash
    of all the local non-volatile facts. If either is out of date, it will
    download a new catalog. Finally, it will apply the most current catalog.
  EOT

  action(:synchronize) do
    default
    summary "Apply the latest catalog."
    description 'Single run of puppet agent, downloading a new catalog if required.'
    returns 'Nothing'
    examples <<-'EOT'
      Trigger a Puppet run with the configured puppet master:

      $ puppet sockpuppet
    EOT
    notes <<-'EOT'
      This action requires that the puppet master's `auth.conf` file allow save
      access to the `facts` REST terminus. Puppet agent does not use this
      facility, and it is turned off by default. See
      <http://docs.puppetlabs.com/guides/rest_auth_conf.html> for more details.
    EOT

    Puppet.settings.define_settings(:main,
      :volatile_facts => {
        :default  => "",
        :desc     => "A list of facts which cannot invalidate the cache.",
      },
    )

    when_invoked do |options|
      volatile = Puppet.settings[:volatile_facts].split(",") << '_timestamp'
      cachefile = "#{Puppet.settings[:statedir]}/cache.yaml"
      cache     = YAML.load_file(cachefile) if File.exists? cachefile
      cache   ||= {}

      facts    = Puppet::Node::Facts.indirection.find(Puppet[:certname])
      facts    = facts.values.reject { |fact, value| volatile.include? fact }
      facthash = Digest::MD5.hexdigest(facts.sort_by{ |k,v| k }.to_s)
      revision  = Puppet::Face[:revision, '0.0.1'].find(Puppet.settings[:server])

      if facthash != cache[:facthash] or revision != cache[:revision]
        Puppet::Face[:plugin, '0.0.1'].download
        Puppet::Face[:facts, '0.0.1'].upload
      #  Puppet::Face[:catalog, '0.0.1'].download
        File.write(cachefile, {:facthash => facthash, :revision => revision}.to_yaml)
      else
        Puppet.notice "Using cached catalog"
        Puppet.debug  "=>Sockpuppet::facthash: #{facthash}"
        Puppet.debug  "=>Sockpuppet::revision: #{revision}"
      end

      report = Puppet::Face[:catalog, '0.0.1'].apply
      Puppet::Face[:report, '0.0.1'].submit(report)
    end
  end
end
