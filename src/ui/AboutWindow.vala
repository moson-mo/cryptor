using Gtk;
using Cryptor.Data;

namespace Cryptor.UI {
    [GtkTemplate (ui = "/org/moson/cryptor/ui/AboutWindow.ui")]
    public class AboutWindow : AboutDialog {
        public AboutWindow (Window parent) {
            Object (
                transient_for: parent
            );
        }
    }
}