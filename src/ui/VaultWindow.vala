using Gtk;
using Cryptor.Data;

namespace Cryptor.UI {
    [GtkTemplate (ui = "/org/moson/cryptor/ui/VaultWindow.ui")]
    public class VaultWindow : Dialog {
        Config config;
        int row;

        [GtkChild]
        private unowned Entry entry_vault;

        [GtkChild]
        private unowned Entry entry_name;

        [GtkChild]
        private unowned Entry entry_mountpoint;

        [GtkChild]
        private unowned Entry entry_mode;

        [GtkChild]
        private unowned ComboBox combo_mode;

        [GtkChild]
        private unowned CheckButton check_reverse;

        public VaultWindow (Window parent, int row, Config config) {
            Object (
                transient_for: parent
            );
            this.config = config;
            this.row = row;
            if (row != -1 && config.vaults.size > row) {
                var v = config.vaults[row];
                check_reverse.active = v.reverse;
                entry_name.text = v.name;
                entry_vault.text = v.path;
                entry_mountpoint.text = v.mount_point;
                combo_mode.active_id = v.mode;
            }
            if (row == -1) {
                this.title = _("New vault");
            } else {
                this.title = _("Edit vault");
            }
        }

        [GtkCallback]
        private void on_browse_mountpoint_clicked (Button bt) {
            var bfd = new FileChooserDialog (_("Browse"), this, FileChooserAction.SELECT_FOLDER, _("Browse"), ResponseType.OK, _("Cancel"), ResponseType.CANCEL);
            bfd.set_position (WindowPosition.CENTER_ON_PARENT);

            bfd.show_all ();
            bfd.response.connect ((dialog, result) => {
                if (result == ResponseType.OK) {
                    try {
                        var dir = Dir.open (bfd.get_filename (), 0);
                        var file = dir.read_name ();
                        if (file != null) {
                            Utils.show_error (this, _("Directory is not empty. Please choose an empty directory."));
                        } else {
                            entry_mountpoint.text = bfd.get_filename ();
                            bfd.destroy ();
                        }
                    } catch (Error e) {
                        Utils.show_error (this, e.message);
                    }
                } else {
                    bfd.destroy ();
                }
            });
        }

        [GtkCallback]
        private void on_browse_vault_clicked (Button bt) {
            var bfd = new FileChooserDialog (_("Browse"), this, FileChooserAction.SELECT_FOLDER, _("Browse"), ResponseType.OK, _("Cancel"), ResponseType.CANCEL);
            bfd.set_position (WindowPosition.CENTER_ON_PARENT);

            bfd.show_all ();
            bfd.response.connect ((dialog, result) => {
                if (result == ResponseType.OK) {
                    var path = bfd.get_filename ();
                    var gocryptfs_path = path + "/gocryptfs.conf";
                    var reverse_path = path + "/.gocryptfs.reverse.conf";
                    if (!check_reverse.active && !File.new_for_path (gocryptfs_path).query_exists ()) {
                        if (Utils.show_question (this, "%s\n%s".printf (_("gocryptfs.conf file does not seem to exist."), _("Do you want to create a new vault?"))) == ResponseType.YES) {
                            try {
                                var dir = Dir.open (bfd.get_filename (), 0);
                                var f = dir.read_name ();
                                if (f != null) {
                                    Utils.show_error (this, "%s\n%s".printf (_("Directory is not empty."), _("Choose an empty directory to initialize a new vault.")));
                                    return;
                                }
                            } catch (Error e) {
                                Utils.show_error (this, e.message);
                                return;
                            }
                            string ? pw;
                            if (!get_new_password (out pw)) {
                                return;
                            }
                            try {
                                Gocrypt.init_vault (path, pw, false);
                                Utils.show_info (this, _("New vault has been created."));
                            } catch (Error e) {
                                Utils.show_error (this, "%s\n%s".printf (_("Error creating new vault:"), e.message));
                                return;
                            }
                        } else {
                            return;
                        }
                    } else if (check_reverse.active && !File.new_for_path (reverse_path).query_exists ()) {
                        if (Utils.show_question (this, "%s\n%s".printf (_(".gocryptfs.reverse.conf file does not seem to exist."), _("Do you want to create a new reverse-vault?"))) == ResponseType.YES) {
                            string ? pw;
                            if (!get_new_password (out pw)) {
                                return;
                            }
                            try {
                                Gocrypt.init_vault (path, pw, true);
                                Utils.show_info (this, _("New reverse vault has been created."));
                            } catch (Error e) {
                                Utils.show_error (this, "%s\n%s".printf (_("Error creating new reverse-vault:"), e.message));
                                return;
                            }
                        } else {
                            return;
                        }
                    }
                    entry_vault.text = path;
                    bfd.destroy ();
                } else {
                    bfd.destroy ();
                }
            });
        }

        [GtkCallback]
        private void on_cancel_vault_clicked (Button bt) {
            this.close ();
        }

        [GtkCallback]
        private void on_save_vault_clicked (Button bt) {
            if (entry_vault.text == "" || entry_mountpoint.text == "") {
                Utils.show_error (this, _("Vault location and mount point need to be specified."));
                return;
            }
            Vault v = new Vault ();
            if (row == -1) {
                config.vaults.add (v);
            } else if (config.vaults.size > row) {
                v = config.vaults[row];
            }
            v.name = entry_name.text;
            v.path = entry_vault.text;
            v.mount_point = entry_mountpoint.text;
            v.mode = combo_mode.active_id;
            v.reverse = check_reverse.active;

            config.changes_made = true;

            this.close ();
        }

        [GtkCallback]
        private void on_check_reverse_toggled (ToggleButton tb) {
            entry_vault.text = "";
            entry_mountpoint.text = "";
            if (tb.active) {
                combo_mode.active_id = "rw";
                entry_mode.sensitive = false;
                combo_mode.sensitive = false;
            } else {
                entry_mode.sensitive = true;
                combo_mode.sensitive = true;
            }
        }

        private bool get_new_password (out string ? password) {
            password = null;
            var pw = Utils.show_password_entry (this, false, true);
            if (pw == null) {
                return false;
            }
            var pw2 = Utils.show_password_entry (this, true, true);
            if (pw2 == null) {
                return false;
            }
            if (pw != pw2) {
                Utils.show_error (this, _("Entered passwords do not match."));
                return false;
            }
            password = pw;
            return true;
        }
    }
}
