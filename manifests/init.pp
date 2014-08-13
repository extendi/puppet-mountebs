class mountebs {

  mount {'umount /mnt':
    name => "/mnt",
    ensure => "absent"
  }

  # create if not present beanstalkd and apps
  file { '/mnt/beanstalkd':
    ensure => "directory"
  }

  file { '/mnt/apps':
    ensure => "directory"
  }

  mount { '/mnt/beanstalkd':
    ensure => mounted
  }

  mount { '/mnt/apps':
    ensure => mounted
  }

  package {'mdadm':
    ensure => present
  }

  mdadm { '/dev/md0' :
    ensure    => 'created',
    devices   => ['/dev/xvdb', '/dev/xvdc'],
    level     => 0,
    force     => true,
    notify    => Exec['format /dev/md0']
  }

  exec {'format /dev/md0':
    command => 'mkfs.ext4 -j -F /dev/md0',
    path => '/sbin',
    refreshonly => true,
    notify => File['set tmp mount point'],
  }

  file {'set tmp mount point':
    path => '/tmp',
    ensure => directory,
    mode => 'a=rwx,o=t',
  }



  exec {'label /tmp':
    command => "e2label /dev/md0 instance_store",
    path => "/sbin"
  }

  mount {'/tmp':
    ensure => 'mounted',
    atboot => true,
    device => 'LABEL=instance_store',
    options => 'defaults'
  }


  Mount['umount /mnt'] -> File['/mnt/beanstalkd'] -> File['/mnt/apps'] -> Mount['/mnt/beanstalkd'] -> Mount['/mnt/apps'] -> Package['mdadm'] -> Mdadm['/dev/md0'] -> Exec['label /tmp'] -> Mount['/tmp']


}