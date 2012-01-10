#include <stdio.h>
#include <stdlib.h>

#include "solve.h"
#include "dancing-links.h"

int main(int argc, char **argv) {
    dlx_matrix *input = create_dlx_matrix();
    struct dlx_matrix_row *dlx_row = add_dlx_row(input);
    long solutions;
    int value;

    while (scanf("%d", &value)) {
        if (value < -1) {
            break;
        }
        if (value == -1) {
            dlx_row = add_dlx_row(input);
        }
        else {
            add_dlx_value(dlx_row, value);
        }
    }

    solutions = solve_dancing_links(input);
    printf("%ld\n", solutions);

    destroy_dlx_matrix(input);

    return EXIT_SUCCESS;
}
