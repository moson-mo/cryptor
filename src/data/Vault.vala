namespace Cryptor.Data {
    public class Vault : Object, Json.Serializable {
        public string name { get; set; }
        public string path { get; set; }
        public string mount_point { get; set; }
        public string mode { get; set; }
        public bool reverse { get; set; }
        public bool is_mounted () {
            string cmd = "mountpoint -q " + this.mount_point;
            bool result = false;
            string standard_error;
            int status;
            try {
                Process.spawn_command_line_sync (cmd, null, out standard_error, out status);
            } catch (Error e) {
                throw e;
            } finally {
                if (status == 0) {
                    result = true;
                } 
            }
            return result;
        }
    }
}
