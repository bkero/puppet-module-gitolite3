class gitolite3::packages {
    $gitwebpkg = $::operatingsystem? {
        'CentOS' => 'gitweb',
        'RedHat' => 'gitweb-caching'
    }

    package {
        ['gitolite3', $gitwebpkg]:
            ensure  => installed,
            require => Yumrepo['epel'];
    }
}
