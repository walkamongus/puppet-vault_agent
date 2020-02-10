# @api private
# @summary Download Vault executable, unpack and create any necessary user and group
class vault_agent::install (
  Stdlib::Httpurl $source,
  Boolean $manage_user,
  Boolean $manage_group,
  String $user,
  String $group,
  Boolean $manage_vault_binary,
  Boolean $create_download_dir,
  Stdlib::Unixpath $download_dir,
  Stdlib::Unixpath $vault_bin_dir,
){

  assert_private()

  if $manage_vault_binary {
    if $create_download_dir {
      file { $download_dir:
        ensure => directory,
        before => Archive['vault_archive'],
      }
    }

    archive { 'vault_archive':
      ensure       => present,
      path         => "${download_dir}/${basename($source)}",
      extract      => true,
      extract_path => $vault_bin_dir,
      source       => $source,
      cleanup      => true,
      creates      => "${vault_bin_dir}/vault",
    }

    file { 'vault':
      path    => "${vault_bin_dir}/vault",
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Archive['vault_archive'],
    }
  }

  if $manage_user {
    user { $user: ensure => present }
  }

  if $manage_group {
    group { $group: ensure => present }
  }

}
