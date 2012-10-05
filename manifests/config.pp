class gitolite3::config {
#    include ldap_users::com
#    include ldap_users::net
#    include ldap_users::org
#    include ldap_users::logins
#    Ssh_Authorized_Key <| user == 'gitolite' |> { notify => Exec['refresh-authkeys'] }

    # Default file permissions
    File {
        owner => $gitolite3::user,
        group => $gitolite3::group,
        mode  => 0600,
    }

    file {
        'gitweb.conf':
            ensure  => present,
            path    => '/etc/gitweb.conf',
            mode    => '0644',
            content => template('gitolite3/gitweb.conf.erb');

        'robots.txt':
            ensure  => present,
            path    => '/var/www/gitweb-caching/robots.txt',
            mode    => '0644',
            content => "User-agent: *\nDisallow: /\n";

        'gitolite.rc':
            ensure  => present,
            path    => "$gitolite3::root/.gitolite.rc",
            mode    => '0644',
            require => File[$gitolite3::root],
            content => template('gitolite3/gitolite.rc.erb');

        'web-bindir':
            ensure => directory,
            path   => '/var/www/bin/',
            owner  => 'gitolite3',
            group  => 'gitolite3',
            mode   => '0755';

        'gitolite-suexec-wrapper.sh':
            ensure  => present,
            path    => "/var/www/bin/gitolite-suexec-wrapper.sh",
            mode    => '0755',
            owner   => 'gitolite3',
            group   => 'gitolite3',
            require => File['web-bindir'],
            content => template('gitolite3/gitolite-suexec-wrapper.sh.erb');

        'ssh-authkeys':
            ensure  => present,
            path    => '/usr/share/gitolite3/triggers/post-compile/ssh-authkeys',
            source  => 'puppet:///modules/gitolite3/ssh-authkeys',
            mode    => '0755',
            require => Package['gitolite3'];

        'gitweb-caching.conf':
            ensure  => present,
            path    => '/etc/httpd/conf.d/gitweb-caching.conf',
            mode    => '0644',
            notify  => Service['httpd'],
            content => template('gitolite3/gitweb.httpd.conf.erb');

        'gitweb-caching':
            ensure  => directory,
            path    => '/var/www/gitweb-caching',
            mode    => '0755',
            recurse => true;
    }

    exec { 'refresh-authkeys':
        cwd         => $gitolite3::root,
        command     => '/usr/bin/gitolite trigger SSH_AUTHKEYS',
        user        => $gitolite3::user,
        environment => "HOME=$gitolite3::root",
        refreshonly => true,
    }

    if $gitolite3::ldap == true {
        file {'ldap-group-query.sh':
            ensure => present,
            path   => '/usr/local/bin/ldap-group-query.sh',
            mode   => '0700',
            content => template('gitolite3/ldap-group-query.sh.erb');
        }
    }

    user { 'apache':
        ensure  => present,
        groups  => 'gitolite3',
    }

}
