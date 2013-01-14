# sshauth::key::server
# Install a public key into a server user's authorized_keys(5) file.
#
# This definition is private, i.e. it is not intended to be called directly by users.  Called by sshauth::key to generate an exported resource and by sshauth::server to realize the resource tagged by namevar (the keyname).
#
# === Parameters: see sshauth::server
#
# === Usage:
#   # from sshauth::key
#   @@sshauth::key::server { $name:
#       ensure  => $ensure,
#       user    => $_user,
#       options => $options,
#       tag     => $name,
#   }
#   
#   # from sshauth::server
#   Sshauth::Key::Server <<| tag == $name |>>
#
define sshauth::key::server (
    $ensure,
    $user,
    $options,
) {

    include sshauth::params
    
    # on the keymaster:
    $key_src_dir  = "${sshauth::params::keymaster_storage}/${name}"
    $key_src_file = "${key_src_dir}/key.pub"
    $key_src_content = file($key_src_file, '/dev/null')
    #notify {"sshauth::key::server: ensure is= $ensure":}
    #notify {"sshauth::key::server: user is= $user":}
    #notify {"sshauth::key::server: options is= $options":}
    #notify {"sshauth::key::server: key_src_content is= $key_src_content":}


    # If absent, remove from authorized_keys
    if $ensure == 'absent' {
        ssh_authorized_key { $name: 
	    ensure => absent,
            user   => $user,
         }

    # If no key content, do nothing.  wait for keymaster to realise key resource
    } elsif ! $key_src_content {
        notify { "Public key file ${key_src_file} for key ${name} not found on keymaster; skipping": }

    # Make sure key content parses
    } elsif $key_src_content !~ /^(ssh-...) ([^ ]*)/ {
        err("Can't parse public key file ${key_src_file}")
        notify { "Can't parse public key file ${key_src_file} for key ${name} on the keymaster: skipping": }

    # All's good.  install the pubkey.
    } else {
        $keytype = $1
        $modulus = $2
        #notify {"sshauth::key::server: keytype is= $keytype":}
        #notify {"sshauth::key::server: modulus is= $modulus":}
        
        ssh_authorized_key { $name:
            ensure  => present,
            user    => $user,
            type    => $keytype,
            key     => $modulus,
            options => $options ? {
                ''      => undef,
                default => $options,
            },
        }
    }
}
