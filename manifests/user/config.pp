# sshauth::user::config
define sshauth::user::config (
    $user,
    $ssh_aliases={},
) {

    include sshauth::params

    # get homedir and primary group of $user
    $home = gethomedir($user)

    file { "${home}/.ssh/config":
        content => template("sshauth/user_config.erb"),
    }
}
