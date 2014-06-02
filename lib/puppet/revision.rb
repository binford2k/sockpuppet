require 'puppet/indirector'

class Puppet::Revision
  extend Puppet::Indirector
  indirects :revision, :terminus_class => :local

  attr :revision, true

  def initialize( revision = nil )
    @revision = revision || {}
  end

  def to_data_hash
    @revision
  end

  def to_pson(*args)
    @revision.to_pson
  end

  def self.from_pson(pson)
    if pson.include?('revision')
      self.new(pson['revision'])
    else
      self.new(pson)
    end
  end

  def name
    "revision"
  end

  def name=(name)
    # NOOP
  end

end

