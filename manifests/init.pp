class mountebs {

  exec {'unmount instance store':
    command => "umount /mnt"
  }

  # create if not present beanstalkd and apps
  file { '/mnt/beanstalkd':
    ensure => "directory"
  }

  file { '/mnt/apps':
    ensure => "directory"
  }

  mount { '/dev/xvdb':
    ensure => absent
  }

  Exec['unmount instance store'] -> File['/mnt/beanstalkd'] -> File['/mnt/apps'] -> Upstart::Job['memcached'] -> Mount['/dev/xvdb']
}