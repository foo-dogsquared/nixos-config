project('run-workflow-with-vm',
  version: '2024-05-17',
  license: 'GPL-3.0-or-later',
  meson_version: '>=0.54.0',
)

prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
sysconfdir = join_paths(prefix, get_option('sysconfdir'))

includedInputs = get_option('inputs')
inputsArgs = ''
foreach input : includedInputs
  inputsArgs += '-I ' + input + ' \\\n    '
endforeach

bindata = configuration_data()
bindata.set('datadir', datadir)
bindata.set('inputsArgs', inputsArgs)
bindata.set('projectname', meson.project_name())
configure_file(
  input: 'app.sh',
  output: meson.project_name(),
  configuration: bindata,
  install_dir: get_option('bindir'),
  install_mode: 'rwxr-xr-x',
  install: true
)

install_data(
  './configuration.nix',
  './modules/home-manager/default.nix',
  './modules/nixos/default.nix',
  install_mode: 'r--r--r--',
  preserve_path: true,
)
