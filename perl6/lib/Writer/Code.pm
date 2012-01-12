class Writer::Code {
    has &.code;

    method write(@solution) {
        &!code(@solution);
    }
}
