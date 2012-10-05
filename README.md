Gitolite puppet module
======================

Introduction
------------
This module will allow you to easily deploy gitolite for your project or
organization.  Some of the benefits include:

* easy integration of LDAP SSH public keys (using an external module)
* LDAP groupings.  You can still use LDAP groups to manage user permissions
* Gitweb integration
* Per-repository hook architecture

Some limitations are:

* As of now it's only compatible with RHEL.  Some package and filenames are
  different for other distros, but I don't have time to test them lately.
* Some other puppet module are realized in this one (an internal mozilla
  yumrepo and an epel yumrepo).  I've left a commented-out version of
  yumrepo-epel inside init.pp
* The define-class could be better.  Ideally each repo would be it's own type,
  however I haven't had time to sit down and code that part out yet.

    node "git1.example.com" {
        class { 'gitolite':
            ldap            => true,
            ldap_bindpw     => "mypassword",
            ldap_user       => "uid=mybinduser,ou=logins,dc=mycompany",
            ldap_pass       => "hunter2",
            ldap_searchbase => "ou=groups,dc=mycompany",
    }
