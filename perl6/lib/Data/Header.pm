use Data::Object;

class Data::Header does Data::Object {
    has Int $.S = 0;

    method increase-S { $!S++; return }
    method decrease-S { $!S--; return }
}
