# Class: gitolite
#
# This module manages gitolite
#
# Parameters:
#   root: Directory to store root filesystem (default: /var/lib/gitolite)
#   user: User to run gitolite as (default: gitolite3)
#   group: Group to run gitolite as (default: gitolite3)
#   showall: List all repositories in gitweb (default: false)
#
#   LDAP-centric parameters
#   ldap: Whether to use ldap to manage users (default: false)
#   ldap_host: LDAP's bind host (default: '')
#   ldap_user: LDAP's bind username (default: '')
#   ldap_pass: LDAP's bind password (default: '')
#   ldap_searchbase: LDAP's searchbase (default: '')
#
#   SSL-centric parameters
#   ssl: Use SSL or not (default: false)
#   sslcert: Location of certificate (default: '/etc/httpd/ssl/gitweb.crt')
#   sslkey: Location of SSL private key (default: '/etc/httpd/ssl/gitweb.key')
#
# Actions:
#
#   Installs, configures, and manages a gitolite instance
#
# Requires:
#
# Sample Usage:
#
#   class { "gitolite":
#       $root      => '/repo',
#       $ldap      => true,
#       $ldap_host => 'localhost',
#       $ldap_user => 'gitolite',
#       $ldap_pass => 'hunter2'
#       $ldap_searchbase => 'ou=groups,dc=mycompany'
#   }
#
# [Remember: No empty lines between comments and class definition]
class gitolite3 ($root='/var/lib/gitolite3',
                 $user='gitolite3',
                 $group='gitolite3',
                 $showall=false,
                 $ldap=false,
                 $ldap_host='',
                 $ldap_user='',
                 $ldap_pass='',
                 $ldap_searchbase='',
                 $ssl=false,
                 $sslcert='/etc/httpd/ssl/gitweb.crt',
                 $sslkey='/etc/httpd/ssl/gitweb.key'
    ) {

    if defined(File[$gitolite3::root]) == false {
        file { $gitolite3::root:
            ensure => present,
            owner  => $gitolite3::user,
            group  => $gitolite3::group;
        }
    }

    if $ldap == true {
        $no_setup_authkeys = 1
        $enable_external_membership_program = true
        if $ldap_pass == '' {
            fail('You probably need a bind password (ldap_pass param)')
        }
        if $ldap_user == '' {
            fail('You probably need a bind username (ldap_user param)')
        }
        if $ldap_host == '' {
            fail('You probably need a bind hostname (ldap_host param)')
        }
        if $ldap_searchbase == '' {
            fail('You probably need a bind search base (ldap_searchbase param)')
        }
        class { 'gitolite3::user': before => Class['gitolite3::config']; }
    } else {
        $no_setup_authkeys = 0
        $enable_external_membership_program = false
    }


    Yumrepo <| title == 'epel' |>
    Yumrepo <| title == 'mozilla' |>

    #### This is unnecessary with other mozilla classes ####
    #yumrepo { 'epel':
    #    mirrorlist => "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch",
    #    enabled    => 1,
    #    gpgcheck   => 0,
    #}
    #file {
    #    $gitolite3::root:
    #        mode => '0755',
    #        ensure => directory;
    #}

    if $gitolite3::root != '/var/lib/gitolite3' {
        file { '/var/lib/gitolite3':
            ensure => link,
            path   => "/var/lib/gitolite3",
            target => $gitolite3::root,
        }
    }

    file {
        'privdir':
            ensure  => directory,
            path    => "${gitolite3::root}/.gitolite",
            owner   => 'gitolite3',
            group   => 'gitolite3',
            require => Class['gitolite3::packages'];

        'keydir':
            ensure  => directory,
            path    => "${gitolite3::root}/.gitolite/keydir",
            owner   => 'gitolite3',
            group   => 'gitolite3',
            require => File['privdir'];

        'logs':
            ensure  => directory,
            path    => "${gitolite3::root}/.gitolite/logs",
            owner   => 'gitolite3',
            group   => 'gitolite3',
            require => File['privdir'];
    }

    class {
        'gitolite3::packages': before => Class['gitolite3::config'];
        'gitolite3::config':
            user                               => $user,
            group                              => $group,
            ldap                               => $ldap,
            ldap_host                          => $ldap_host,
            ldap_user                          => $ldap_user,
            ldap_pass                          => $ldap_pass,
            ldap_searchbase                    => $ldap_searchbase,
            ssl                                => $ssl,
            sslcert                            => $sslcert,
            sslkey                             => $sslkey,
            root                               => $root,
            no_setup_authkeys                  => $no_setup_authkeys,
            enable_external_membership_program => $enable_external_membership_program,
            showall                            => $showall;
    }
}

