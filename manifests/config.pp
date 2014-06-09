class gitolite3::config (
    $user,
    $group,
    $root,
    $ldap,
    $ldap_host,
    $ldap_user,
    $ldap_pass,
    $ldap_searchbase,
    $ssl,
    $sslcert,
    $sslkey,
    $no_setup_authkeys,
    $enable_external_membership_program,
    $showall
) {

    # Default file permissions
    File {
        owner => $user,
        group => $group,
        mode  => '0600',
    }

    file {
        'gitconfig':
            ensure  => present,
            path    => '/etc/gitconfig',
            mode    => '0644',
            source  => 'puppet:///modules/gitolite3/gitconfig';

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
            path    => "${root}/.gitolite.rc",
            mode    => '0644',
            require => File[$root],
            content => template('gitolite3/gitolite.rc.erb');

        'web-bindir':
            ensure => directory,
            path   => '/var/www/bin/',
            owner  => 'gitolite3',
            group  => 'gitolite3',
            mode   => '0755';

        'gitolite-suexec-wrapper.sh':
            ensure  => present,
            path    => '/var/www/bin/gitolite-suexec-wrapper.sh',
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
        cwd         => $root,
        command     => '/usr/bin/gitolite trigger SSH_AUTHKEYS',
        user        => $user,
        environment => "HOME=${root}",
        refreshonly => true,
    }

    if $ssl == true {
        file {
            'gitweb-https':
                ensure  => present,
                path    => '/etc/httpd/conf.d/gitweb-caching-https.conf',
                mode    => '0644',
                notify  => Service['httpd'],
                content => template('gitolite3/gitweb-https.httpd.conf.erb');
        }
    }

    if $ldap == true {
        file {'ldap-group-query.sh':
            ensure  => present,
            path    => '/usr/local/bin/ldap-group-query.sh',
            mode    => '0700',
            content => template('gitolite3/ldap-group-query.sh.erb');
        }
    }

    user { 'apache':
        ensure  => present,
        groups  => 'gitolite3',
    }

}
