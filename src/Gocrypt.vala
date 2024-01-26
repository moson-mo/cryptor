namespace Cryptor {
    public class Gocrypt {
        public static void init_vault (string path, string password, bool reverse) throws Error {
            string ? standard_error;
            string cmd = "gocryptfs -init -q";
            if (reverse) {
                cmd += "-reverse";
            }
            cmd += " -- " + path;

            var sp = new Subprocess.newv (cmd.split (" "), SubprocessFlags.STDIN_PIPE | SubprocessFlags.STDERR_PIPE | SubprocessFlags.STDOUT_PIPE);
            sp.communicate_utf8 (password + "\n" + password + "\n", null, null, out standard_error);
            var status = sp.get_exit_status ();

            if (standard_error != null && standard_error != "") {
                throw new Error (Quark.from_string ("Cryptor"), status, remove_color (standard_error));
            }
        }

        public static void mount_vault (string path, string mountpoint, string password, bool ro, bool reverse, string custom_options) throws Error {
            string ? standard_error;
            var cmd = "gocryptfs -q";
            if (ro) {
                cmd += "-ro";
            }
            if (reverse) {
                cmd += "-reverse";
            }
            if (custom_options != "") {
                cmd += custom_options;
            }
            cmd += " -- " + path + " " + mountpoint;
            var sp = new Subprocess.newv (cmd.split (" "), SubprocessFlags.STDIN_PIPE | SubprocessFlags.STDERR_PIPE | SubprocessFlags.STDOUT_PIPE);
            sp.communicate_utf8 (password + "\n", null, null, out standard_error);
            var status = sp.get_exit_status ();

            if (standard_error != null && standard_error != "") {
                throw new Error (Quark.from_string ("Cryptor"), status, remove_color (standard_error));
            }
        }

        public static void unmount_vault (string mountpoint) throws Error {
            string ? standard_output, standard_error;

            Process.spawn_command_line_sync ("fusermount -u " + mountpoint, out standard_output, out standard_error, null);

            if (standard_error != null && standard_error != "") {
                throw new Error (Quark.from_string ("Cryptor"), 3, standard_error);
            }
        }

        public static string ? get_master_key (string path, string password) throws Error {
            string ? standard_output, standard_error;
            string[] cmd = { "gocryptfs-xray", "-dumpmasterkey", path + "/gocryptfs.conf" };

            var sp = new Subprocess.newv (cmd, SubprocessFlags.STDIN_PIPE | SubprocessFlags.STDERR_PIPE | SubprocessFlags.STDOUT_PIPE);
            sp.communicate_utf8 (password + "\n", null, out standard_output, out standard_error);
            var status = sp.get_exit_status ();

            if (standard_error != null && standard_error != "") {
                throw new Error (Quark.from_string ("Cryptor"), status, standard_error);
            }
            if (status != 0) {
                throw new Error (Quark.from_string ("Cryptor"), status, standard_output);
            }

            return standard_output;
        }

        private static string remove_color (string str) {
            return str.replace ("\033[31m", "").replace ("\033[33m", "").replace ("\033[0m", "");
        }
    }
}
