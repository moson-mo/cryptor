using Cryptor.Data;

namespace Cryptor {
    public class Config : GLib.Object, Json.Serializable {
        public bool changes_made;

        public bool umount_on_quit { get; set; }
        public bool autosave_on_quit { get; set; }
        public bool show_tray_icon { get; set; }
        public bool send_to_tray { get; set; }

        public Gee.ArrayList<Vault> vaults { get; set; }

        public Config () {
            changes_made = false;
            umount_on_quit = true;
            autosave_on_quit = false;
            show_tray_icon = false;
            send_to_tray = false;
            vaults = new Gee.ArrayList<Vault> ();
        }

        public static Config from_file (string path) throws Error {
            size_t len;
            string json;
            FileUtils.get_contents (path, out json, out len);
            return (Config) Json.gobject_from_data (typeof (Config), json, (ssize_t) len);
        }

        public void save_to_file (string path) throws FileError {
            size_t len;
            var json = Json.gobject_to_data (this, out len);
            FileUtils.set_contents_full (path, json, (ssize_t) len, FileSetContentsFlags.CONSISTENT, 0644);
        }

        public virtual Json.Node serialize_property (string property_name, Value @value, ParamSpec pspec) {
            if (@value.type ().is_a (typeof (Gee.ArrayList))) {
                unowned Gee.ArrayList<Object> list_value = @value as Gee.ArrayList<GLib.Object>;
                if (list_value != null || property_name == "data") {
                    var array = new Json.Array.sized (list_value.size);
                    foreach (var item in list_value) {
                        array.add_element (Json.gobject_serialize (item));
                    }

                    var node = new Json.Node (Json.NodeType.ARRAY);
                    node.set_array (array);
                    return node;
                }
            }
            return default_serialize_property (property_name, @value, pspec);
        }

        public virtual bool deserialize_property (string property_name, out Value @value, ParamSpec pspec, Json.Node property_node) {
            if (property_name == "vaults" && property_node.get_node_type () == Json.NodeType.ARRAY) {
                var array = property_node.get_array ();
                var list = new Gee.ArrayList<Vault> ();
                foreach (var node in array.get_elements ()) {
                    list.add ((Vault) Json.gobject_deserialize (typeof (Vault), node));
                }
                var v = Value (typeof (Gee.ArrayList));
                v.set_object (list);
                @value = v;
                return true;
            }
            return default_deserialize_property (property_name, out @value, pspec, property_node);
        }
    }
}
