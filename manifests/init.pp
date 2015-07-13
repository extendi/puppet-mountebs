class mountebs (
  $current_app = '/mnt/apps/pulsarplatform/current',
  $set_tmp_dir = true
){

  exec {'umount cmd for mnt':
    path => '/bin',
    command => 'umount -l /mnt',
    onlyif => 'df -h|grep xvdb'
  }

  mount {'umount /mnt':
    name => "/mnt",
    ensure => "absent"
  }

  file { '/mnt/apps':
    ensure => "directory",
    owner => 'ubuntu',
    group => 'ubuntu',
  }

  mount { '/mnt/apps':
    device => 'LABEL=apps',
    ensure => mounted,
    atboot => true,
    fstype => "ext4",
    options => 'defaults'
  }

  file {'/home/ubuntu/current':
    target => $current_app,
    ensure => 'link'
  }

  if ($set_tmp_dir) {
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
      command     => 'mkfs.ext4 -j -F /dev/md0',
      path        => '/sbin',
      refreshonly => true,
      notify      => Exec['label /tmp']
    }

    file {'set tmp mount point':
      path     => '/tmp',
      ensure   => directory,
      mode     => 'ug=rwx,o=rwxt'
    }

    # potrebbe esserci un problema se non fa il label prima del mount. Controllare perché aggiunto il refreshonly
    exec {'label /tmp':
      command     => "e2label /dev/md0 instance_store",
      path        => "/sbin",
      refreshonly => true
    }

    mount {'/tmp':
      ensure    => 'mounted',
      atboot    => true,
      device    => 'LABEL=instance_store',
      fstype    => 'auto',
      options   => 'defaults'
    }
    
    Exec['umount cmd for mnt'] -> Mount['umount /mnt'] -> File['/mnt/apps'] -> Mount['/mnt/apps'] -> File['/home/ubuntu/current'] -> Package['mdadm'] -> Mdadm['/dev/md0'] -> Mount['/tmp'] -> File['set tmp mount point']
    
  }else{
    Exec['umount cmd for mnt'] -> Mount['umount /mnt'] -> File['/mnt/apps'] -> Mount['/mnt/apps'] -> File['/home/ubuntu/current']
  }

}