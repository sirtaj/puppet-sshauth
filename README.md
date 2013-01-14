sshauth
=======

Module sshauth provides centralized creation, distribution, and revocation of
ssh keys for users. This modules was adapted from the ssh::auth module by
Andrew E. Schulman <andrex at alumni dot utexas dot net>.  For full
documentation of Andrew's version please refer to
http://projects.puppetlabs.com/projects/1/wiki/Module_Ssh_Auth_Patterns

I am expanding on the work Atha Kouroussis's sshauth module
https://github.com/vurbia/puppet-sshauth.  This implementation has changed the
use of virtual resources to exported resources. While it adds the burden of
enabling storeconfigs, the main advantage is that keys can be declared
contextually and not at central location so the keymaster can see them.



User Classes:
-------------
- sshauth::keymaster: 	Create key storage; create, regenerate, and remove key pairs.
- sshauth::key:      	  Declare keys as exported resources.
- sshauth::client:      Install generated key pairs onto clients.
- shauth::server:     	Install public keys onto ssh servers.

Private Classes:
----------------
- sshauth::key::master:	Create/regenerate/remove a key pair on the keymaster.
- sshauth::key::client:	Install a key pair into a user's account.
- sshauth::key::server:	Install a public key into a server user's authorized_keys(5) file.
- sshauth::key::namecheck:	Check a name (e.g. key title or filename) for the allowed form.



# Facts: #
- getent_passwd::		Returns passwd entry for all users using "getent".
- getent_group::		Returns groups entry for all groups using "getent".



# Functions: #
- gethomedir::		Returns home directory name of user specified in args[0].
- getgroup::		Returns primary group of user specified in args[0].



Usage Examples:
-------------------


## sshauth::keymaster ##
Create the keystore on the keymaster node.  Currently this must be the puppet master host:

    include "sshauth::keymaster"

## sshauth::key ##
declare keypair named 'unixsys' with all defaults:

    sshauth::key {"unixsys": }

set alturnate keyfile name for clients:

    sshauth::key {"unixsys": filename => 'id_rsa-grall' }

set user account for this key to agould.  set encryption type to dsa:

    sshauth::key { "unixsys": user => "agould", type => "dsa" }

remove all instances of 'unixsys' keys on ssh clients, servers and keymaster:

    sshauth::key {"unixsys": ensure => 'absent' }

## sshauth::client ##
Install keypair "unixsys" without overriding any original parameters:

    sshauth::client {"unixsys": }

override $user parameter on this client

    sshauth::client {"unixsys": user => 'agould' }

override $user and $filename parameters.  This installs the 'unixsys' keypair into agould's account with alturnate keyname

    sshauth::client {"unixsys": user => 'agould', filename => 'id_rsa-blee'}

remove 'unixsys' keys from agould's account:

    sshauth::client {"unixsys": user => 'agould', ensure => 'absent'}

## sshauth::server ##
install unixsys pubkey into agould's authorized_keys file:

    sshauth::server {"unixsys": user => 'agould'}

install into agould's account, only allow client with ip 192.168.0.5:

    sshauth::server {"unixsys": user => 'agould', options => 'from "192.168.0.5"'}

remove unixsys pubkey from agould's authorized_keys file:

    sshauth::server {"unixsys": ensure => 'absent',user => 'agould'}




To Do:
------

- add andrew's original docs on key revocation and rotation.
- use hiera as the keystore backend
- addablity to install the same pubkey into multiple user accounts on a single node
