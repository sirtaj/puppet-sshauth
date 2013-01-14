# = Class: sshauth::keymaster
# The Keymaster host manages ssh key storage.  It creates, regenerates and removes key pairs.
# 
# === Provides:
# - Set up key storage
# - Collect all exported master keys
#
# === Requires:
# This class must be included on the puppet master server only.
#
# === Usage:
#   include "sshauth::keymaster"
#
class sshauth::keymaster {

    include sshauth::params
    
    # Set up key storage
    file { $sshauth::params::keymaster_storage:
        ensure => directory,
        owner  => 'puppet',
        group  => 'puppet',
        mode   => '0644',
    }

    # Collect all exported master keys
    Sshauth::Key::Master <<| |>>
}
