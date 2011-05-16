== Reader

A `Reader` accepts a human-readable problem description, and emits an
exact cover matrix.

    my $human-input = q:to'END';
        type: sudoku
        
        53. .7. ...
        6.. 195 ...
        .98 ... .6.
        
        8.. .6. ..3
        4.. 8.3 ..1
        7.. .2. ..6
        
        .6. ... 28.
        ... 419 ..5
        ... .8. .79
        END
    
    my $reader = ReaderFactory.create_from($human-input);
    my $matrix = $reader.matrix;
    
    # $matrix can now be passed to a Solver; see 03-solver.md

A human-readable problem description is an ordinary string consisting of
two parts -- a header and a body -- separated by an empty line. The
header is made up entirely of key-value pairs of this form:

    size: 9x9

(That is, the line must contain a colon, and at least some
non-whitespace before and after the colon. Whitespace around the colon
is ignored.)

Apart from the `type` key, which decides which `Reader` is to be used,
all key-value pairs are optional. A key can only be used if the
particular `Reader` subclass recognizes that key. (The recognized keys
are the return value of the `.recognized_keys` method.) Keys may not
appear more than one time in the same input.

The body is simply the rest of the description, once the header and the
empty line have been consumed. What makes up a valid body is entirely up
to the `Reader` subclass. The body can even be the empty string; if it
is, there is no need to include the empty line either. However, A
`Reader` subclass may choose to reject the empty string (just as with
any other body) if it does not specify the problem adequately.

It is possible to instantiate a `Reader` subclass using its `.new`
method, passing in a header and body:

    my %header;           # empty; 'type: sudoku' coded as C<SudokuReader>
    my Str $body = '...'; # as above
    
    my $reader = Reader::Sudoku.new(:%header, :$body);

But the `ReaderFactory` class will instantiate things for you, while
also relieving you of manual handling of `%header` and `$body`.

A `Reader` has two additional methods:

* `.matrix`, which returns the (sparse) exact cover matrix, to be
consumed by a `Solver`. (See `03-solver.md`.) The qualifier "sparse"
here means that instead of zeroes and ones, each line of the matrix
lists only the (zero-based) column indices where the ones appear.

* `.writer`, which returns a `Writer` object configured to output
results from a `Solver` that look like the human-readable problem
description in `$body`. (See `04-writer.md`.)
