project('mosey-branch',
  version: '2023-08-11',
  license: 'GPL-3.0-or-later',
  meson_version: '>=0.54.0',
)

app_id = 'one.foodogsquared.MoseyBranch'
prefix = get_option('prefix')
bindir = join_paths(prefix, get_option('bindir'))
datadir = join_paths(prefix, get_option('datadir'))
systemddir = join_paths(prefix, 'share/systemd')
applicationsdir = join_paths(datadir, 'applications')
systemduserdir = join_paths(systemddir, 'user')
autostartdir = join_paths(prefix, 'etc/xdg/autostart')
unit_name_template = app_id + '.@0@.@1@'

required_components = {
  'polkit': {
    'description': 'Authentication agent for the desktop service',
    'script': get_option('polkit_script'),
  },
  'ibus': {
    'description': 'Input method engine for the desktop service',
    'script': get_option('ibus_script'),
  },
  'ags': {
    'description': 'Widget system',
    'script': get_option('ags_script'),
  },
}

session_dropins = [
  'gnome-session@mosey-branch.target.d',
]

session_wants = ''
foreach name, component : required_components
  session_wants += 'Wants=' + unit_name_template.format(name, 'target') + '\n'
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
  output: 'mosey-branch.desktop',
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

configure_file(
  input: 'mosey-branch.desktop.in',
  output: app_id + '.desktop',
  install_dir: applicationsdir,
  configuration: serviceconf,
  install: true,
)

# Setting up for installing with the core services systemd units.
required_services = []
foreach name, component : required_components
  required_services += unit_name_template.format(name, 'target')
endforeach

gnomesessionconf = configuration_data()
gnomesessionconf.set(
  'required_components',
  ';'.join(required_services + [ (app_id + '.target') ]) + ';'
)
configure_file(
  input: 'mosey-branch.session',
  output: 'mosey-branch.session',
  install_dir: datadir / 'gnome-session/sessions',
  configuration: gnomesessionconf,
  install: true,
)

runconf = configuration_data()
configure_file(
  input: 'mosey-branch.bin.in',
  output: 'mosey-branch-session',
  install_dir: bindir,
  configuration: runconf,
  install: true,
)

foreach name, component : required_components
  componentsconf = configuration_data()
  componentsconf.set('component', name)
  componentsconf.set('app_id', app_id)
  componentsconf.set('description', component.get('description'))
  componentsconf.set('script', component.get('script'))
  componentsconf.set('gsm_phase', component.get('gsm_phase', 'Desktop'))

  configure_file(
    input: 'core-service.service.in',
    output: unit_name_template.format(name, 'service'),
    install_dir: systemduserdir,
    configuration: componentsconf,
    install: true,
  )

  configure_file(
    input: 'core-service.target.in',
    output: unit_name_template.format(name, 'target'),
    install_dir: systemduserdir,
    configuration: componentsconf,
    install: true,
  )

  configure_file(
    input: 'core-service.desktop.in',
    output: unit_name_template.format(name, 'desktop'),
    install_dir: autostartdir,
    configuration: componentsconf,
    install: true,
  )
endforeach
