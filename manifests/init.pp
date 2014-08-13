class mountebs {

  mount {'umount /mnt':
    name => "/mnt",
    ensure => "umounted"
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

  Mount['umount /mnt'] -> File['/mnt/beanstalkd'] -> File['/mnt/apps'] -> Mount['/mnt/beanstalkd'] -> Mount['/mnt/apps']
}