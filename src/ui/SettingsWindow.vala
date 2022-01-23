using Gtk;
using Cryptor.Data;

namespace Cryptor.UI {
    [GtkTemplate (ui = "/org/moson/cryptor/ui/SettingsWindow.ui")]
    public class SettingsWindow : Dialog {
        private Config config;
        bool prev_send_to_tray;

        [GtkChild]
        private unowned CheckButton check_unmount;

        [GtkChild]
        private unowned CheckButton check_autosave;

        [GtkChild]
        private unowned CheckButton check_show_tray;

        [GtkChild]
        private unowned CheckButton check_send_to_tray;


        public SettingsWindow (Window parent, Config config) {
            Object (
                transient_for: parent
            );
            this.config = config;
            check_unmount.active = config.umount_on_quit;
            check_autosave.active = config.autosave_on_quit;
            check_show_tray.active = config.show_tray_icon;
            check_send_to_tray.active = config.send_to_tray;
            prev_send_to_tray = config.send_to_tray;
        }

        [GtkCallback]
        private void on_save_settings_clicked (Button bt) {
            config.umount_on_quit = check_unmount.active;
            config.autosave_on_quit = check_autosave.active;
            config.show_tray_icon = check_show_tray.active;
            config.send_to_tray = check_send_to_tray.active;
            config.changes_made = true;
            this.close ();
        }

        [GtkCallback]
        private void on_cancel_settings_clicked (Button bt) {
            this.close ();
        }

        [GtkCallback]
        private void on_check_show_tray_toggled (ToggleButton cb) {
            if (cb.active) {
                check_send_to_tray.sensitive = true;
                check_send_to_tray.active = prev_send_to_tray;
            } else {
                check_send_to_tray.active = false;
                check_send_to_tray.sensitive = false;
            }
        }
    }
}