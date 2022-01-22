namespace Cryptor.Data {
    public class Vault : Object, Json.Serializable {
        public string name { get; set; }
        public string path { get; set; }
        public string mount_point { get; set; }
        public string mode { get; set; }
        public bool reverse { get; set; }
        public bool is_mounted;
    }
}
