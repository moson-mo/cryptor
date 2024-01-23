using Gtk;
using Cryptor.Data;
using GLib;

namespace Cryptor.UI {
    [GtkTemplate (ui = "/org/moson/cryptor/ui/CryptorWindow.ui")]
    public class CryptorWindow : ApplicationWindow {
        private Config config;
        private StatusIcon ? tray;
        private string ? _config_path;
        private string ? config_path {
            get {
                return _config_path;
            } set {
                _config_path = value;
                if (label_status != null) {
                    label_status.label = _("Config file") + ": " + value;
                }
            }
        }

        [GtkChild]
        private unowned Gtk.ListStore list_store;

        [GtkChild]
        private unowned TreeSelection tree_selection;

        [GtkChild]
        private unowned Label label_status;

        public CryptorWindow (Gtk.Application app) {
            Object (
                application: app
            );

            config = new Config ();
            var dir = Environment.get_user_config_dir () + "/cryptor/";
            var file = dir + "cryptor.conf";
            if (File.new_for_path (file).query_exists ()) {
                try {
                    config = Config.from_file (file);
                    if (config.vaults != null) {
                        config_path = file;
                        sync_treeview_from_conf ();
                    } else {
                        config.vaults = new Gee.ArrayList<Vault> ();
                    }
                } catch (Error e) {
                }
            } else {
                try {
                    DirUtils.create_with_parents (dir, 0755);
                    config.save_to_file (file);
                    config_path = file;
                } catch (Error e) {
                }
            }
            this.delete_event.connect (save_before_quit);
            show_tray_icon ();
        }

        public void show_or_not_show () {
            if (config.start_minimized && tray != null) {
                this.hide ();
            } else {
                this.show_all ();
            }
        }

        [GtkCallback]
        private void on_mi_quit_activate (Gtk.MenuItem mi) {
            save_before_quit (null, null);
            this.destroy ();
        }

        [GtkCallback]
        private void on_mi_save_as_activate (Gtk.MenuItem ? mi) {
            var fdc = new FileChooserDialog (_("Save"), this, FileChooserAction.SAVE, _("Save"), ResponseType.OK, _("Cancel"), ResponseType.CANCEL);
            if (config_path == null) {
                var confdir_path = Environment.get_user_config_dir () + "/cryptor/";
                var confdir = File.new_for_path (confdir_path);
                if (!confdir.query_exists ()) {
                    try {
                        confdir.make_directory ();
                        fdc.set_current_folder (confdir_path);
                    } catch (Error e) {
                    }
                } else {
                    fdc.set_current_folder (confdir_path);
                }
            }
            fdc.set_current_name ("cryptor.conf");
            fdc.set_do_overwrite_confirmation (true);
            fdc.set_position (WindowPosition.CENTER_ON_PARENT);
            fdc.set_filter (get_conf_filter ());

            var result = fdc.run ();

            if (result == ResponseType.OK) {
                try {
                    config.save_to_file (fdc.get_filename ());
                    config_path = fdc.get_filename ();
                    config.changes_made = false;
                } catch (Error e) {
                    Utils.show_error (this, e.message);
                }
            } else {
            }
            fdc.destroy ();
        }

        [GtkCallback]
        private void on_mi_save_activate (Gtk.MenuItem mi) {
            if (config_path == null) {
                on_mi_save_as_activate (mi);
            } else {
                try {
                    config.save_to_file (config_path);
                    config.changes_made = false;
                } catch (Error e) {
                    Utils.show_error (this, e.message);
                }
            }
        }

        [GtkCallback]
        private void on_mi_open_activate (Gtk.MenuItem mi) {
            var fdc = new FileChooserDialog (_("Open"), this, FileChooserAction.OPEN, _("Open"), ResponseType.OK, _("Cancel"), ResponseType.CANCEL);
            fdc.set_current_name ("cryptor.conf");
            fdc.set_position (WindowPosition.CENTER_ON_PARENT);
            fdc.set_filter (get_conf_filter ());

            fdc.show_all ();
            fdc.response.connect ((dialog, result) => {
                if (result == ResponseType.OK) {
                    try {
                        config_path = fdc.get_filename ();
                        config = Config.from_file (config_path);
                        if (config.vaults == null) {
                            Utils.show_error (this, _("Error loading vaults."));
                            return;
                        }
                        sync_treeview_from_conf ();
                        fdc.destroy ();
                        show_tray_icon ();
                    } catch (Error e) {
                        Utils.show_error (this, e.message);
                    }
                } else {
                    fdc.destroy ();
                }
            });
        }

        [GtkCallback]
        private void on_mi_about_activate (Gtk.MenuItem mi) {
            var win = new AboutWindow (this);
            win.response.connect ((dialog, response) => {
                if (response == ResponseType.DELETE_EVENT) {
                    dialog.close ();
                }
            });
            win.show ();
        }

        [GtkCallback]
        private void on_mi_settings_activate (Gtk.MenuItem mi) {
            var win = new SettingsWindow (this, config);

            win.destroy.connect (() => {
                show_tray_icon ();
            });
            win.show_all ();
        }

        [GtkCallback]
        private bool on_tree_view_button_press (Widget w, Gdk.EventButton e) {
            if (e.button == Gdk.BUTTON_SECONDARY) {
                show_menu ();
            }
            return false;
        }

        [GtkCallback]
        private void on_mi_new_vault_activate (Gtk.MenuItem mi) {
            show_vault_window (-1);
        }

        [GtkCallback]
        private void on_mi_refresh_activate (Gtk.MenuItem mi) {
            sync_treeview_from_conf ();
        }

        private void show_tray_icon () {
            if (!config.show_tray_icon) {
                if (tray != null) {
                    tray.dispose ();
                    tray = null;
                }
                return;
            }
            tray = new StatusIcon.from_icon_name ("gtk-dialog-authentication");
            tray.button_release_event.connect ((ev) => {
                if (ev.button == 1) {
                    if (this.is_visible ()) {
                        this.hide ();
                    } else {
                        this.show_all ();
                        sync_treeview_from_conf ();
                    }
                } else if (ev.button == 3) {
                    var menu = new Gtk.Menu ();
                    menu.reserve_toggle_size = false;
                    var show = UI.Utils.get_image_menu_item (this.is_visible () ? "gtk-close" : "gtk-open", this.is_visible () ? _("Hide") : _("Show"));
                    show.activate.connect (() => {
                        if (this.is_visible ()) {
                            this.hide ();
                        } else {
                            this.show_all ();
                            sync_treeview_from_conf ();
                        }
                    });
                    menu.append (show);
                    var quit = UI.Utils.get_image_menu_item ("gtk-quit", _("Quit"));
                    quit.activate.connect (() => {
                        save_before_quit (null, null);
                        this.destroy ();
                    });
                    menu.append (quit);
                    menu.show_all ();
                    menu.popup_at_pointer (null);
                }

                return false;
            });
        }

        private void on_mount_clicked (Gtk.MenuItem mi) {
            var vault = get_selected_vault ();
            if (vault == null) {
                return;
            }

            if (!vault.is_mounted) {
                var password = Utils.show_password_entry (this, false, false);
                if (password == null) {
                    return;
                }
                try {
                    Gocrypt.mount_vault (vault.path, vault.mount_point, password, (vault.mode == "r"), vault.reverse, vault.custom_options);
                    sync_treeview_from_conf ();
                } catch (Error e) {
                    if (e.message.contains ("fusermount exited with code 256")) {
                        if (Utils.show_question (this, "%s\n\n%s\n%s".printf (e.message, _("Vault might be mounted already."), _("Shall I retry unmounting it first?"))) == ResponseType.YES) {
                            try {
                                Gocrypt.unmount_vault (vault.mount_point);
                                Gocrypt.mount_vault (vault.path, vault.mount_point, password, (vault.mode == "r"), vault.reverse, vault.custom_options);
                                sync_treeview_from_conf ();
                            } catch (Error e) {
                                Utils.show_error (this, "%s\n%s".printf (_("Error re-mounting vault:"), e.message));
                            }
                        }
                    } else {
                        Utils.show_error (this, "%s\n%s".printf (_("Error mounting vault:"), e.message));
                    }
                }
            } else {
                try {
                    Gocrypt.unmount_vault (vault.mount_point);
                    sync_treeview_from_conf ();
                } catch (Error e) {
                    Utils.show_error (this, "%s\n%s".printf (_("Error unmounting vault:"), e.message));
                }
            }
        }

        private void show_menu () {
            var vault = get_selected_vault ();
            if (vault == null) {
                return;
            }
            var menu = new Gtk.Menu ();
            menu.reserve_toggle_size = false;
            var open = Utils.get_image_menu_item ("gtk-open", _("Open directory"));
            open.sensitive = vault.is_mounted;
            open.activate.connect (() => {
                Utils.open_folder (vault.mount_point);
            });
            var mount = Utils.get_image_menu_item (vault.is_mounted ? "gtk-cancel" : "gtk-apply", vault.is_mounted ? _("Unmount") : _("Mount"));
            mount.activate.connect (on_mount_clicked);
            var edit = Utils.get_image_menu_item ("gtk-edit", _("Edit"));
            edit.sensitive = !vault.is_mounted;
            edit.activate.connect (() => {
                show_vault_window (get_selected_rownumber ());
            });
            var remove = Utils.get_image_menu_item ("gtk-remove", _("Remove"));
            remove.sensitive = !vault.is_mounted;
            remove.activate.connect (() => {
                config.vaults.remove (vault);
                sync_treeview_from_conf ();
            });
            menu.add (open);
            menu.add (mount);
            menu.add (edit);
            menu.add (remove);
            menu.show_all ();
            menu.popup_at_pointer (null);
        }

        private void show_vault_window (int row) {
            var nv = new VaultWindow (this, row, config);
            nv.close.connect (() => {
                sync_treeview_from_conf ();
            });
            nv.show ();
        }

        private Vault ? get_selected_vault () {
            var rn = get_selected_rownumber ();
            if (rn == -1 || rn > config.vaults.size) {
                return null;
            }
            return config.vaults[rn];
        }

        private int get_selected_rownumber () {
            int r = -1;
            TreeIter iter;
            TreeModel model;
            if (tree_selection.get_selected (out model, out iter)) {
                var path = model.get_path (iter);
                if (path != null) {
                    r = path.get_indices ()[0];
                }
            }
            return r;
        }

        private FileFilter get_conf_filter () {
            var ff = new FileFilter ();
            ff.set_name ("Cryptor config");
            ff.add_pattern ("*.conf");
            return ff;
        }

        private void sync_treeview_from_conf () {
            foreach (var vault in config.vaults) {
                var entry = new UnixMountEntry (vault.mount_point, null);
                vault.is_mounted = entry != null;
            }
            list_store.clear ();
            foreach (var v in config.vaults) {
                TreeIter iter;
                var mode = _("Read-Only");
                if (v.mode == "rw" || v.mode == "Read-Write") {
                    mode = _("Read-Write");
                }
                list_store.append (out iter);
                list_store.set_value (iter, 0, v.name);
                list_store.set_value (iter, 1, v.reverse);
                list_store.set_value (iter, 2, v.path);
                list_store.set_value (iter, 3, v.mount_point);
                list_store.set_value (iter, 4, mode);
                list_store.set_value (iter, 5, v.is_mounted);
            }
        }

        private bool save_before_quit (Widget ? w, Gdk.EventAny ? ev) {
            if (config.send_to_tray && w != null && tray != null) {
                this.hide ();
                return true;
            }
            if (config.umount_on_quit) {
                foreach (var vault in config.vaults) {
                    if (vault.is_mounted) {
                        try {
                            Gocrypt.unmount_vault (vault.mount_point);
                        } catch (Error e) {
                        }
                    }
                }
            }
            if (config.autosave_on_quit) {
                if (config_path != null && config_path != "") {
                    try {
                        config.save_to_file (config_path);
                    } catch (Error e) {
                        Utils.show_error (this, "%s\n%s".printf (_("Unable to save configuration file:"), e.message));
                        return true;
                    }
                }
            } else {
                if (config.changes_made) {
                    if (Utils.show_question (this, "%s\n%s".printf (_("Seems you've made changes to the configuration."), _("Do you want to save them?"))) == ResponseType.YES) {
                        if (config_path != null && config_path != "") {
                            try {
                                config.save_to_file (config_path);
                            } catch (Error e) {
                                Utils.show_error (this, "%s\n%s".printf (_("Unable to save configuration file:"), e.message));
                                return true;
                            }
                        } else {
                            on_mi_save_as_activate (null);
                        }
                    }
                }
            }
            return false;
        }

        /*
           private bool get_selected_is_mounted () {
            TreeIter iter;
            TreeModel model;
            if (tree_selection.get_selected (out model, out iter)) {
                Value val;
                model.get_value (iter, 5, out val);
                return val.get_boolean ();
            }
            return false;
           }

           private void set_selected_is_mounted (bool ismounted) {
            TreeIter iter;
            TreeModel model;
            if (tree_selection.get_selected (out model, out iter)) {
                list_store.set_value (iter, 5, ismounted);
            }
           }
         */
    }
}
