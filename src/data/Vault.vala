namespace Cryptor.Data {
    public class Vault : Object, Json.Serializable {
        public string name { get; set; }
        public string path { get; set; }
        public string mount_point { get; set; }
        public string mode { get; set; }
        public bool reverse { get; set; }
        public string custom_options { get; set; default = ""; }
        public bool is_mounted;
    }
}
