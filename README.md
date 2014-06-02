Introduction
============

_**Alert**: this module is not currently usable_

This is a module that allows you to drastically reduce the load on your Puppet
Master if you fall within a very narrow use case.

Two things go into the building of a Puppet catalog: the code that is compiled,
and the data that goes into it. If both remain constant, then the resulting
catalog should be exactly the same and we don't need to compile it again; the
Agent can simply apply the last cached catalog.

This means that the Agent node continues to be managed but only requests an
updated catalog when necessary.

This module expects you to write a `config_version` script that returns the
codebase revision of all code that goes into building a catalog. This likely
includes the entire Puppet `modulepath` and any Hiera datasources.

Features:

* REST endpoint exposing the Puppet Master's computed `config_version`
* Puppet subcommand to replace the Agent, while only downloading a new catalog
  when the cache is invalidated.

Limitations
============

This is still in early development. Pull requests are welcome!

* The Master's REST endpoint is not currently operational.
* The `sockpuppet` face depends on the core `catalog` face, which is currently broken.

Usage
============


### On the Master:

* Install the module
* Configure a `config_version` to return the codebase revision of anything
  that could affect the compiled catalog
    * Puppet codebase
    * Hiera datasources
    * etc.

### On the Agent:

* Install the module
* Add a `volatile_facts` setting to `puppet.conf` that contains a list of all
  facts that change often and should not trigger a recompile.
* Disable the Puppet Agent daemon
* Configure a cron job to run `puppet sockpuppet` on the schedule of your choice.

#### Suggested default list of volatile facts.

    [main]
      volatile_facts = memoryfree,swapfree,swapfree_mb,memoryfree_mb,uptime,uptime_days,uptime_hours,uptime_seconds

Contact
=======

* Author: Ben Ford
* Email: binford2k@gmail.com
* Twitter: @binford2k
* IRC (Freenode): binford2k
