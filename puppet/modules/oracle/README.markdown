[![Build Status](https://travis-ci.org/hajee/oracle.png?branch=master)](https://travis-ci.org/hajee/oracle)

####Table of Contents

[![Powered By EasyType](https://raw.github.com/hajee/easy_type/master/powered_by_easy_type.png)](https://github.com/hajee/easy_type)


1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with oracle](#setup)
    * [What oracle affects](#what-oracle-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with oracle](#beginning-with-oracle)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
    * [OS support](#os-support)
    * [Oracle versions support](#oracle-version-support)
    * [Managable Oracle objects](#managable-oracle-objects)
    * [Tests - Testing your configuration](#testing)

##Overview

This module contains a couple of Puppet custom types to manage 'stuff' in an Oracle database. At this point in time we support manage tablespacses, oracle users, grants, roles and services. To learn more, check [the blog post](http://hajee.github.io/2014/02/23/using-puppet-to-manage-oracle/)

##Module Description

This module contains custom types that can help you manage DBA objects in an Oracle database. It runs **after** the database is installed. IT DOESN'T INSTALL the Oracle database software. With this module, you can setup a database to receive an application. You can:

* create a tablespace
* create a user with the required grants and quota's
* create one or more roles
* create one or more services 

##Setup

###What oracle affects

The types in this module will change settings **inside** a Oracle Database. No changes will be made outside of the database. 

###Setup Requirements

To use this module, you need a running Oracle database. I can recommend [Edwin Biemonds Puppet OraDb module](https://github.com/biemond/puppet/tree/master/modules/oradb). The Oracle module itself is based on [easy_type](https://github.com/hajee/easy_type).

###Beginning with oracle module

After you have a running database, (See [Edwin Biemonds Puppet OraDb module](https://github.com/biemond/puppet/tree/master/modules/oradb)), you need to install [easy_type](https://github.com/hajee/easy_type), and this module.

```sh
puppet module install hajee/easy_type
puppet module install hajee/oracle
```

##Usage

The module contains the following types:

`tablespace`, `oracle_user`, `role` and `listener`. Here are a couple of examples on how to use them.

###listener

This is the only module that does it's work outside of the Oracle database. It makes sure the Oracle SQL*Net listener is running. 

```puppet
listener {'listener':
  ensure  => running,
  require => Exec['db_install_instance'],
}
```

###oracle_user

This type allows you to manage a user inside an Oracle Database. It recognises most of the options that [CREATE USER](http://docs.oracle.com/cd/B28359_01/server.111/b28286/statements_8003.htm#SQLRF01503) supports. Besides these options, you can also use this type to manage the grants and the quota's for this user.

```puppet
oracle_user{user_name:
  temporary_tablespace      => temp,
  default_tablespace        => 'my_app_ts,
  password                  => 'verysecret',
  require                   => Tablespace['my_app_ts'],
  grants                    => ['SELECT ANY TABLE', 'CONNECT', 'CREATE TABLE', 'CREATE TRIGGER'],
  quotas                    => {
                                  "my_app_ts"  => 'unlimited'
                                },
}
```

###tablespace

This type allows you to manage a tablespace inside an Oracle Database. It recognises most of the options that [CREATE TABLESPACE](http://docs.oracle.com/cd/B28359_01/server.111/b28310/tspaces002.htm#ADMIN11359) supports. 

```puppet
tablespace {'my_app_ts':
  ensure                    => present,
  size                      => 20G,
  logging                   => yes,
  autoextend                => on,
  next                      => 100M,
  max_size                  => 12288M,
  extent_management         => local,
  segment_space_management  => auto,
}
```

###role

This type allows you to create or delete a role inside an Oracle Database. It recognises a limit part of the options that [CREATE ROLE](http://docs.oracle.com/cd/B28359_01/server.111/b28286/statements_6012.htm#SQLRF01311) supports. 


```puppet
role {'just_a_role':
  ensure    => present,
}
```

###oracle_service

his type allows you to create or delete a service inside an Oracle Database. 


```puppet
oracle_service{'my_app_service':
  ensure  => present,
}
```

##Limitations

 This module is tested on Oracle 11 on CentOS and Redhat. It will probably work on other Linux distributions. It will definitely **not** work on Windows. As far as Oracle compatibility. Most of the sql commands's it creates under the hood are pretty much Oracle version independent. It should work on most Oracle versions. 

##Development

This is an open projects, and contributions are welcome. 

###OS support

Currently we have tested:

* Oracle 11.2.0.2 & 11.2.0.4
* CentOS 5.8
* Redhat 5

It would be great if we could get it working and tested on:

* Oracle 12
* Debian
* Windows
* Ubuntu
* ....

###Oracle version support

Currently we have tested:

* Oracle 11.2.0.2
* Oracle 11.2.0.4

It would be great if we could get it working and tested on:

* Oracle 12

###Managable Oracle objects

Obviously Oracle has many many many more DBA objects that need management. For some of these Puppet would be a big help. It would be great if we could get help getting this module to support all of the objects.

If you have knowledge in these technologies, know how to code, and wish to contribute to this project, we would welcome the help.

###Testing

Make sure you have:

* rake
* bundler

Install the necessary gems:

    bundle install

And run the tests from the root of the source code:

    rake test

We are currently working on getting the acceptance test running as well.



[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/hajee/oracle/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

