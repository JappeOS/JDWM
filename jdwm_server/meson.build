project(
  'jdwm_server',
  'c',
  version: '0.0.1',
  #license: 'MIT',
  meson_version: '>=0.46.0',
  default_options: [
    'c_std=c11',
    'warning_level=2',
    'werror=true',
  ],
)

add_global_arguments(
  [
    '-DWLR_USE_UNSTABLE=1',
    '-DHAVE_WAYLAND=1',
    '-DPACKAGE_NAME="' + meson.project_name() + '"',
    '-DPACKAGE_VERSION="' + meson.project_version() + '"',
    '-Wno-unused-parameter',
    '-Wno-unused-result',
    '-Wno-missing-braces',
    '-Wundef',
    '-Wvla'
  ],
  language: 'c',
)

jdwm_server_inc = include_directories('include')

cc = meson.get_compiler('c')
math = cc.find_library('m', required : true)

wayland_server = dependency('wayland-server')
wayland_cursor = dependency('wayland-cursor')
wayland_client = dependency('wayland-client')
wayland_egl    = dependency('wayland-egl')
wayland_protos = dependency('wayland-protocols', version: '>=1.17')
xkbcommon      = dependency('xkbcommon')
cairo          = dependency('cairo')
pango          = dependency('pango')
libinput       = dependency('libinput')
pangocairo     = dependency('pangocairo')
glesv2         = dependency('glesv2')
egl            = dependency('egl')
xcb            = dependency('xcb')
pixman         = dependency('pixman-1')

wlroots = dependency('wlroots', version: '>=0.14.0')

subdir('protocols')

#--

jdwm_server_src = files(
  'src/server.c',
  )

jdwm_server_dep = [
  wayland_server,
  cairo,
  pango,
  pangocairo,
  libinput,
  glesv2,
  wlroots,
  xkbcommon,
  math,
  xcb,
  pixman
  ]

executable(
  'jdwm_server',
  jdwm_server_src,
  include_directories: [jdwm_server_inc],
  dependencies: [jdwm_server_dep, server_protos],
  install: true,
  )