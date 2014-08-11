group { 'puppet': ensure => present }
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'] }

# --- Preinstall Stage ---------------------------------------------------------

stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { 'apt-get -y update':
    unless => "test -e ${home}/.rvm"
  }
}
class { 'apt_get_update':
  stage => preinstall
}

# -------------------------------------------------------------------------------

package { [
    'build-essential',
    'git-core',
    'cmake',
    'python-software-properties'
  ]:
  ensure  => 'installed',
}

exec { 'add:ppa:boost':
  command => "sudo apt-add-repository ppa:boost-latest/ppa -y && sudo apt-get -y update",
  require => Package['python-software-properties']
}

package { [
    'libboost1.54-dev',
    'libboost-regex1.54-dev',
    'libboost-program-options1.54-dev',
    'libboost-system1.54.0',
    'libboost-filesystem1.54-dev'
  ]:
  ensure  => 'installed',
  require => Exec['add:ppa:boost'],
}

exec {'clone:tops':
  command => "git clone https://github.com/ayoshiaki/tops.git /tmp/tops && cd /tmp/tops && git submodule update --init && sudo ldconfig && cmake . && make && make install && sudo ldconfig",
  timeout => 1800,
  require => [
    Package['build-essential'],
    Package['git-core'],
    Package['cmake'],
    Package['libboost1.54-dev'],
    Package['libboost-regex1.54-dev'],
    Package['libboost-program-options1.54-dev'],
    Package['libboost-system1.54.0'],
    Package['libboost-filesystem1.54-dev'],
  ],
  creates => '/usr/local/bin/viterbi_decoding'
}
