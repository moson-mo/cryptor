using Gtk;

namespace Cryptor.UI {
    class Utils {
        public static Gtk.MenuItem get_image_menu_item (string icon_name, string label) {
            var mi = new Gtk.MenuItem ();
            var box = new Box (Orientation.HORIZONTAL, 6);
            var icon = new Image.from_icon_name (icon_name, IconSize.MENU);
            var lbl = new Label (label);
            box.add (icon);
            box.add (lbl);
            mi.add (box);
            mi.show_all ();
            return mi;
        }

        public static void show_error (Window parent, string message) {
            var dialog = new MessageDialog (parent, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, "%s", message);
            dialog.run ();
            dialog.destroy ();
        }

        public static ResponseType show_question (Window parent, string message) {
            var dialog = new MessageDialog (parent, DialogFlags.MODAL, MessageType.QUESTION, ButtonsType.YES_NO, "%s", message);
            var result = dialog.run ();
            dialog.destroy ();
            return result;
        }

        public static void show_info (Window parent, string message) {
            var dialog = new MessageDialog (parent, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK, "%s", message);
            dialog.run ();
            dialog.destroy ();
        }

        public static string ? show_password_entry (Window parent, bool reenter, bool newpw) {
            string message;
            string ? ret = null;
            if (newpw) {
                message = _("Please enter a new password:");
            } else {
                message = _("Please enter the password:");
            }
            if (reenter) {
                message = _("Please enter the password again:");
            }

            var dialog = new MessageDialog (parent, DialogFlags.MODAL, MessageType.OTHER, ButtonsType.OK_CANCEL, message);
            var entry = new Entry ();
            var area = dialog.get_content_area ();
            entry.invisible_char = '*';
            entry.visibility = false;
            area.pack_end (entry, false, false, 0);

            dialog.show_all ();
            var result = dialog.run ();
            if (result == ResponseType.OK) {
                ret = entry.text;
            }
            dialog.destroy ();
            return ret;
        }

        public static void open_folder (string path) {
            try {
                Process.spawn_command_line_sync ("xdg-open file://" + path, null, null, null);
            } catch (Error e) {
            }
        }
    }
}
