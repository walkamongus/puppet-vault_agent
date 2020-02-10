# @api private
# @summary Create and populate Vault agent config file
class vault_agent::config (
  Stdlib::Unixpath $config_dir,
  Boolean $purge_config_dir,
  String $user,
  String $group,
  Hash $config,
){

  assert_private()

  file { $config_dir:
    ensure  => directory,
    purge   => $purge_config_dir,
    recurse => $purge_config_dir,
    owner   => $user,
    group   => $group,
  }

  file { "${config_dir}/config.json":
    content => to_json_pretty($config),
    owner   => $user,
    group   => $group,
    mode    => '0640',
  }

}
