project('cryptor', 'vala', 'c')

gnome = import('gnome')

deps = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gio-2.0'),
    dependency('gio-unix-2.0'),
    dependency('gee-0.8'),
    dependency('gtk+-3.0'),
    dependency('json-glib-1.0')
]

src = files([
    'src/CryptorApp.vala',
    'src/Gocrypt.vala',
    'src/Config.vala',
    'src/data/Vault.vala',
    'src/ui/Utils.vala',
    'src/ui/CryptorWindow.vala',
    'src/ui/VaultWindow.vala',
    'src/ui/SettingsWindow.vala',
    'src/ui/AboutWindow.vala'
])

resources = gnome.compile_resources('ui', 'resources/ui.gresource.xml', source_dir: 'resources')

subdir('po')

executable('cryptor',
           resources,
           dependencies: deps,
           sources: src,
           vala_args: [],
           install: true)
