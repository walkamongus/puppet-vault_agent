# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include vault_agent
class vault_agent (
  String $user                               = 'vault-agent',
  String $group                              = 'vault-agent',
  Boolean $manage_user                       = true,
  Boolean $manage_group                      = true,
  Hash $config                               = {},
  Stdlib::Unixpath $config_dir               = '/etc/vault-agent',
  Boolean $purge_config_dir                  = true,
  Optional[Stdlib::Httpurl] $download_source = undef,
  Boolean $manage_vault_binary               = true,
  Stdlib::Httpsurl $hashicorp_releases       = 'https://releases.hashicorp.com/vault',
  String $version                            = '1.3.2',
  Stdlib::Unixpath $download_dir             = '/tmp',
  Boolean $create_download_dir               = false,
  Stdlib::Unixpath $vault_bin_dir            = '/usr/local/bin',
  String $service_name                       = 'vault-agent',
  Boolean $manage_service                    = true,
){

  case $facts['architecture'] {
    /(x86_64|amd64)/: { $arch = 'amd64' }
    'i386':           { $arch = '386'   }
    /^arm.*/:         { $arch = 'arm'   }
    default:          { fail("Unsupported kernel architecture: ${facts['architecture']}") }
  }

  $_hashicorp_url = "${hashicorp_releases}/${version}/vault_${version}_${downcase($facts['kernel']) }_${arch}.zip"
  $_source        = pick($download_source, $_hashicorp_url)

  class {'vault_agent::install':
    source              => $_source,
    manage_user         => $manage_user,
    user                => $user,
    manage_group        => $manage_group,
    group               => $group,
    manage_vault_binary => $manage_vault_binary,
    create_download_dir => $create_download_dir,
    download_dir        => $download_dir,
    vault_bin_dir       => $vault_bin_dir,
  }
  contain 'vault_agent::install'

  class {'vault_agent::config':
    user             => $user,
    group            => $group,
    config           => $config,
    config_dir       => $config_dir,
    purge_config_dir => $purge_config_dir,
  }
  contain 'vault_agent::config'

  class {'vault_agent::service':
    user          => $user,
    group         => $group,
    config_dir    => $config_dir,
    vault_bin_dir => $vault_bin_dir,
  }
  contain 'vault_agent::service'

  Class['vault_agent::install']
  -> Class['vault_agent::config']
  ~> Class['vault_agent::service']
}
