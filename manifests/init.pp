class mountebs {

  mount {'umount /mnt':
    name => "/mnt",
    blockdevice => "/dev/xvdb",
    device => "/dev/xvdb",
    ensure => "unmounted"
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
    force     => true
  }

  filesystem {'/dev/md0':
    ensure => present,
    fs_type => 'ext4',
  }

  exec {'label /tmp':
    command => "e2label /dev/md0 instance_store",
    path => "/sbin"
  }

  mount {'/tmp':
    ensure => 'mounted',
    atboot => true,
    device => 'LABEL=instance_store',
    fstype => 'ext4',
    options => 'defaults'
  }


  Mount['umount /mnt'] -> File['/mnt/beanstalkd'] -> File['/mnt/apps'] -> Mount['/mnt/beanstalkd'] -> Mount['/mnt/apps'] -> Package['mdadm'] -> Mdadm['/dev/md0'] -> Filesystem['/dev/md0'] -> Exec['label /tmp'] -> Mount['/tmp']


}