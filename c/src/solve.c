#include <stdio.h>
#include <stdlib.h>

#include "solve.h"
#include "dancing-links.h"

int main(int argc, char **argv) {
    dlx_matrix *input = create_dlx_matrix();
    struct dlx_matrix_row *dlx_row = add_dlx_row(input);
    solution_matrix *solutions;
    struct solution_matrix_row *solution;
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
    for (solution = solutions->first_row;
         solution != NULL;
         solution = solution->next_row) {

        printf("%s\n", contents(solution));
    }

    destroy_solution_matrix(solutions);
    destroy_dlx_matrix(input);

    return EXIT_SUCCESS;
}
