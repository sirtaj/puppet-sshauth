# sshauth::key::client
# Install a key pair into a user's account.
#
# This definition is private, i.e. it is not intended to be called directly by users.  Called by sshauth::key to generate an exported resource and by sshauth::client to realize the resource tagged by namevar (the keyname).
#
# === Parameters: see sshauth::client
#
# === Usage:
#   # from sshauth::key
#   @@sshauth::key::client { $name:
#       ensure   => $ensure,
#       filename => $_filename,
#       user     => $_user,
#       tag      => $_tag,
#   }
#   
#   # from sshauth::client
#   Sshauth::Key::Client <<| tag == $_tag |>>
#
define sshauth::key::client (
    $user,
    $ensure,
    $filename,
) {

    include sshauth::params

    # get homedir and primary group of $user
    $home = gethomedir($user)
    $group = getgroup($user)
    #notify {"sshauth::key::client: user is= $user":}
    #notify {"sshauth::key::client: home is= $home":}
    #notify {"sshauth::key::client: group is= $group":}
    #notify {"sshauth::key::client: ensure is= $ensure":}

    # filename of private key on the keymaster (source)
    $key_src_file        = "${sshauth::params::keymaster_storage}/${name}/key"

    # filename of private key on the ssh client host (target)
    $key_tgt_file        = "${home}/.ssh/${filename}"

    # contents of public key on the keymaster
    $key_src_content_pub = file("${key_src_file}.pub", '/dev/null')
    

    
    # If 'absent', revoke the client keys
    if $ensure == 'absent' {
        file {[ $key_tgt_file, "${key_tgt_file}.pub" ]: ensure  => 'absent' }

    # test for homedir and primary group
    } elsif ! $home {
        #notify { "Can't determine home directory of user $user": }
        err ( "Can't determine home directory of user $user" )
    } elsif ! $group {
        #notify { "Can't determine primary group of user $user": }
        err ( "Can't determine primary group of user $user" )

    # If syntax of pubkey checks out, install keypair on client
    } elsif ( $key_src_content_pub =~ /^(ssh-...) ([^ ]+)/ ) {
        $keytype = $1
        $modulus = $2

        # QUESTION: what about the homedir?  should we create that if 
        # not defined also? I think not.
        #
        # create client user's .ssh file if defined already
        if ! defined(File[ "${home}/.ssh" ]) {
            file { "${home}/.ssh":
                owner   => $user,
                group   => $group,
                mode    => '700',
                ensure  => directory,
            }
        }

        file { $key_tgt_file:
            content => file($key_src_file, '/dev/null'),
            owner   => $user,
            group   => $group,
            mode    => '0600',
	    require => File["${home}/.ssh"],
        }
        
        file { "${key_tgt_file}.pub":
            content => "${keytype} ${modulus} ${name}\n",
            owner   => $user,
            group   => $group,
            mode    => '0644',
	    require => File["${home}/.ssh"],
        }

    # Else the keymaster has not realized the sshauth::keys::master resource yet
    } else {
        notify { "Private key file ${key_src_file} for key ${name} not found on keymaster; skipping ensure => present": }
    }

}




