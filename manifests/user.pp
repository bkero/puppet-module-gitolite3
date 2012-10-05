class gitolite3::user {
    ssh_authorized_key {
        'myuser':
            user   => 'gitolite3',
            target => '/var/lib/gitolite3/.gitolite/keydir/myuser@gitolite1.pub',
            type   => 'ssh-rsa',
            key    => 'AAAAB3NzaC1...';
        
        'myuser2':
            user   => 'gitolite3',
            target => '/var/lib/gitolite3/.gitolite/keydir/myuser2@gitolite1.pub',
            type   => 'ssh-dss',
            key    => 'AAAAB3NzaC1kc3MAAACBAMUN41NUv...';
    }
}
