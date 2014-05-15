define sshauth::user::ssh_alias (
    $user,
    $group = $user,
    $ssh_alias = {},
    $target    = '',
    $order     = 100,
) {

    $home = gethomedir($user)
    $_target = $target ? {
        ''      => "${home}/.ssh/config",
        default => $target,
    }

    include concat::setup
    if !defined(Concat[$_target]) {
        concat { $_target:
            owner => $user,
            group => $group,
            mode  => 640,
        }
        concat::fragment { "${_target}_header":
            target  => $_target,
            content => "#File Managed by Puppet. Modifications are not recommended.\n\n",
            order   => 01,
        }
    }

    concat::fragment { $name:
        target  => $_target,
        content => template('sshauth/ssh_alias.erb'),
        order   => $order,
    }
}
