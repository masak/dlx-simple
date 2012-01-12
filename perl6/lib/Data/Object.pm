role Data::Object {
    has Data::Object $.L is rw = self;
    has Data::Object $.R is rw = self;
    has Data::Object $.U is rw = self;
    has Data::Object $.D is rw = self;

    method attach-below(Data::Object $other) {
        $other.D.U = self;
        self.D = $other.D;
        self.U = $other;
        $other.D = self;

        return;
    }

    method attach-to-right-of(Data::Object $other) {
        $other.R.L = self;
        self.R = $other.R;
        self.L = $other;
        $other.R = self;

        return;
    }

    method attach-to-left-of(Data::Object $other) {
        $other.attach-to-right-of(self);
    }

    # Shouldn't be needed, because Any should have a method like this
    method ACCEPTS(Any $topic) {
        self === $topic
    }
}        
