# @api private
# @summary Set up Vault agent systemd unit, load it, and start service
class vault_agent::service (
  String $user,
  String $group,
  Stdlib::Unixpath $vault_bin_dir,
  Stdlib::Unixpath $config_dir,
){

  assert_private()

  file { 'vault_agent_service_unit':
    ensure  => file,
    path    => '/etc/systemd/system/vault-agent.service',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('vault_agent/vault-agent.service.epp', {
      'user'          => $user,
      'group'         => $group,
      'config_dir'    => $config_dir,
      'vault_bin_dir' => $vault_bin_dir,
    }),
    notify  => Exec['vault-agent_systemd_daemon-reload'],
  }

  exec { 'vault-agent_systemd_daemon-reload':
    path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command     => 'systemctl daemon-reload > /dev/null',
    refreshonly => true,
  }

  service { 'vault-agent':
    ensure    => running,
    enable    => true,
    subscribe => Exec['vault-agent_systemd_daemon-reload'],
  }

}
