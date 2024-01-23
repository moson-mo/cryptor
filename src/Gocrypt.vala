namespace Cryptor {
    public class Gocrypt {
        public static void init_vault (string path, string password, bool reverse) throws Error {
            string standard_error;
            int status;

            var pfile = write_password_file (password);
            try {
                string cmd = "gocryptfs -init -q ";
                if (reverse) {
                    cmd += "-reverse ";
                }
                cmd += " -passfile " + pfile.get_path () + " -- " + path;
                Process.spawn_command_line_sync (cmd, null, out standard_error, out status);
            } catch (Error e) {
                throw e;
            } finally {
                if (pfile != null) {
                    try {
                        pfile.delete ();
                    } catch (Error e) {
                    }
                }
            }
            if (standard_error != null && standard_error != "") {
                throw new Error (Quark.from_string ("Cryptor"), status, remove_color (standard_error));
            }
        }

        public static void mount_vault (string path, string mountpoint, string password, bool ro, bool reverse, string custom_options) throws Error {
            string standard_error;
            int status;

            var pfile = write_password_file (password);
            var cmd = "gocryptfs -q ";
            if (ro) {
                cmd += "-ro ";
            }
            if (reverse) {
                cmd += "-reverse ";
            }
            if (custom_options != "") {
                cmd += custom_options + " ";
            }
            cmd += " -passfile " + pfile.get_path () + " -- " + path + " " + mountpoint;
            try {
                Process.spawn_command_line_sync (cmd, null, out standard_error, out status);
            } catch (Error e) {
                throw e;
            } finally {
                if (pfile != null) {
                    try {
                        pfile.delete ();
                    } catch (Error e) {
                    }
                }
            }
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

        private static File write_password_file (string password) throws Error {
            FileIOStream ps;
            var temp_file = File.new_tmp (null, out ps);
            var dos = new DataOutputStream (ps.output_stream);
            dos.put_string (password);
            dos.close ();
            return temp_file;
        }

        private static string remove_color (string str) {
            return str.replace ("\033[31m", "").replace ("\033[33m", "").replace ("\033[0m", "");
        }

        /*
           public static void init_vault_stdin (string path, string password) throws Error {

            string[] com = { "gocryptfs", "-init", path };
            Pid pid;
            int sin, sout, serr;

            Process.spawn_async_with_pipes (Environment.get_current_dir (), com, Environ.get (), SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null, out pid, out sin, out sout, out serr);

            var output = FileStream.fdopen (sout, "r");
            string ? o;
            while ((o = output.read_line ()) != null) {
                print ("%s\n", o);
                if (o == "Reading Password from stdin") {
                    var input = FileStream.fdopen (sin, "w");
                    input.write (password.data);
                    input.write ({ '\n' });
                    input.write (password.data);
                }
            }
           }
         */
    }
}
