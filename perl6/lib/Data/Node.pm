use Data::Object;
use Data::Header;

class Data::Node does Data::Object {
    has Int $.row;
    has Data::Header $.C;
}
