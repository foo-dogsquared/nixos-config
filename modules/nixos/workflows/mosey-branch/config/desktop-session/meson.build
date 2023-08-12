project('mosey-branch',
  version: '2023-08-11',
  license: 'GPL-3.0-or-later',
  meson_version: '>=0.54.0',
)

app_id = 'one.foodogsquared.MoseyBranch'
prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
systemddir = join_paths(prefix, 'share/systemd')
systemduserdir = join_paths(systemddir, 'user')

required_components = [
  #'polkit',
  #'ibus',
  #'ags',
]

session_dropins = [
  'gnome-session@mosey-branch.target.d',
]

session_wants = ''
foreach component : required_components
  session_wants += 'Wants=' + app_id + '.' + component + '.target\n'
endforeach

# Install each gnome-session overrides.
sessionconf = configuration_data()
sessionconf.set('session_wants', session_wants)
foreach session_dropin : session_dropins
  configure_file(
    input: 'mosey-branch.session.conf.in',
    output: 'session.conf',
    install_dir: join_paths(systemduserdir, session_dropin),
    configuration: sessionconf,
    install: true
  )
endforeach

# Installing the Wayland session desktop entry.
desktopentryconf = configuration_data()
desktopentryconf.set('session_script', get_option('session_script'))
configure_file(
  input: 'mosey-branch.desktop',
  install_dir: join_paths(datadir, 'wayland-sessions'),
  configuration: desktopentryconf,
  install: true,
)

# Installing the core systemd units for the desktop session.
targetconf = configuration_data()
targetconf.set('app_id', app_id)
configure_file(
  input: 'mosey-branch.target',
  output: app_id + '.target',
  install_dir: systemduserdir,
  configuration: targetconf,
  install: true,
)

serviceconf = configuration_data()
serviceconf.set('script', get_option('service_script'))
configure_file(
  input: 'mosey-branch.service',
  output: app_id + '.service',
  install_dir: systemduserdir,
  configuration: serviceconf,
  install: true,
)

# TODO: Install the systemd units for the core components of the desktop
# environment.
