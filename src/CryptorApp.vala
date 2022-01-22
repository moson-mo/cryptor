using GLib;
using Gtk;

namespace Cryptor {
    public class CryptorApp : Gtk.Application {
        public CryptorApp (string app_name) {
            Object (
                application_id: "org.moson." + app_name,
                flags : ApplicationFlags.FLAGS_NONE,
                register_session: true
            );
            Environment.set_application_name (app_name);            
        }

        protected override void activate () {
            var win = new UI.CryptorWindow (this);
            win.show_all ();
        }

        public static int main (string[] args) {
            var app_name = "cryptor";
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.textdomain (app_name);
            var cryptor = new CryptorApp (app_name);
            return cryptor.run (args);
        }
    }
}
