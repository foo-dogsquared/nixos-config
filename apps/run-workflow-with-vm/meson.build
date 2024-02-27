project('run-workflow-with-vm',
  version: '2024-01-05',
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
  output: 'run-workflow-with-vm',
  configuration: bindata,
  install_dir: get_option('bindir'),
  install_mode: 'rwxr-xr-x',
  install: true
)

install_data(
  './configuration.nix',
  install_mode: 'r--r--r--'
)
