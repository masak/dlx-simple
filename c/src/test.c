#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dancing-links.h"
#include "test.h"

int rows_are_equal(struct solution_matrix_row *actual_row,
                   struct solution_matrix_row *expected_row) {
    struct solution_matrix_value *actual_value = actual_row->first_value,
                                 *expected_value = expected_row->first_value;
    while (1) {
        if (actual_value == NULL && expected_value == NULL) {
            return 1;
        }
        if (actual_value == NULL && expected_value != NULL) {
            return 0;
        }
        if (actual_value != NULL && expected_value == NULL) {
            return 0;
        }
        if (actual_value->value != expected_value->value) {
            return 0;
        }
        actual_value = actual_value->next_value;
        expected_value = expected_value->next_value;
    }
}

char *contents(struct solution_matrix_row *row) {
    char *contents = malloc(50 * sizeof (char));
    struct solution_matrix_value *value = row->first_value;
    contents[0] = '\0';

    strcat(contents, "[");
    while (value != NULL) {
        char *vstring = malloc(10 * sizeof(char));
        sprintf(vstring, "%d", value->value);

        strcat(contents, vstring);
        value = value->next_value;
        if (value != NULL) {
            strcat(contents, ", ");
        }
    }
    strcat(contents, "]");

    return contents;
}

void output_eqv(solution_matrix *actual_output,
                solution_matrix *expected_output,
                char *description) {

    struct solution_matrix_row
        *actual_current_row   = actual_output->first_row,
        *expected_current_row = expected_output->first_row;
    /* yeah yeah, buffer overrun... */
    char *problem = malloc(200 * sizeof (char));
    problem[0] = '\0';

    while (1) {
        if (actual_current_row == NULL && expected_current_row == NULL) {
            break;
        }
        if (actual_current_row == NULL && expected_current_row != NULL) {
            char *expected_contents = contents(expected_current_row);
            strcat(problem, "# Actual row: (missing)\n# Expected row: ");
            strncat(problem, expected_contents, 50);
            strcat(problem, "\n");
            free(expected_contents);
            break;
        }
        if (actual_current_row != NULL && expected_current_row == NULL) {
            char *actual_contents = contents(actual_current_row);
            strcat(problem, "# Actual row: ");
            strncat(problem, actual_contents, 50);
            strcat(problem, "\n# Expected row: (missing)\n");
            free(actual_contents);
            break;
        }
        if (!rows_are_equal(actual_current_row, expected_current_row)) {
            char *expected_contents = contents(expected_current_row);
            char *actual_contents = contents(actual_current_row);
            strcat(problem, "# Actual row: ");
            strncat(problem, contents(actual_current_row), 50);
            strcat(problem, "\n# Expected row: ");
            strncat(problem, contents(expected_current_row), 50);
            strcat(problem, "\n");
            free(actual_contents);
            free(expected_contents);
            break;
        }

        actual_current_row = actual_current_row->next_row;
        expected_current_row = expected_current_row->next_row;
    }
    if (strcmp(problem, "") == 0) {
        printf("ok %d - %s\n", ++test_number, description);
    }
    else {
        printf("not ok %d - %s\n", ++test_number, description);
        printf("%s", problem);
    }
    free(problem);
}

void test_solve(dlx_matrix *input_matrix, solution_matrix *expected_output,
                char *description) {
    solution_matrix *actual_output;

    actual_output = solve_dancing_links(input_matrix);

    output_eqv(actual_output, expected_output, description);
}

void test_that_empty_matrix_gives_one_solution() {
    dlx_matrix *empty_matrix = create_dlx_matrix();
    solution_matrix *one_solution = create_solution_matrix();
    add_solution(one_solution);

    test_solve(empty_matrix, one_solution,
               "empty matrix gives one solution");

    destroy_solution_matrix(one_solution);
    destroy_dlx_matrix(empty_matrix);
}

void test_that_identity_matrix_gives_all_lines() {
    dlx_matrix *identity_matrix = create_dlx_matrix();
    struct dlx_matrix_row *dlx_row;
    solution_matrix *all_lines = create_solution_matrix();
    struct solution_matrix_row *solution;

    dlx_row = add_dlx_row(identity_matrix);
    add_dlx_value(dlx_row, 0);
    dlx_row = add_dlx_row(identity_matrix);
    add_dlx_value(dlx_row, 1);
    dlx_row = add_dlx_row(identity_matrix);
    add_dlx_value(dlx_row, 2);

    solution = add_solution(all_lines);
    add_solution_value(solution, 0);
    add_solution_value(solution, 1);
    add_solution_value(solution, 2);

    test_solve(identity_matrix, all_lines,
               "identity matrix gives all lines");

    destroy_solution_matrix(all_lines);
    destroy_dlx_matrix(identity_matrix);
}

void test_that_2_by_2_candidates_gives_4_solutions() {
    dlx_matrix *two_by_two = create_dlx_matrix();
    struct dlx_matrix_row *dlx_row;
    solution_matrix *four_solutions = create_solution_matrix();
    struct solution_matrix_row *solution;

    dlx_row = add_dlx_row(two_by_two);
    add_dlx_value(dlx_row, 0);
    dlx_row = add_dlx_row(two_by_two);
    add_dlx_value(dlx_row, 0);
    dlx_row = add_dlx_row(two_by_two);
    add_dlx_value(dlx_row, 1);
    dlx_row = add_dlx_row(two_by_two);
    add_dlx_value(dlx_row, 1);

    solution = add_solution(four_solutions);
    add_solution_value(solution, 0);
    add_solution_value(solution, 2);
    solution = add_solution(four_solutions);
    add_solution_value(solution, 0);
    add_solution_value(solution, 3);
    solution = add_solution(four_solutions);
    add_solution_value(solution, 1);
    add_solution_value(solution, 2);
    solution = add_solution(four_solutions);
    add_solution_value(solution, 1);
    add_solution_value(solution, 3);

    test_solve(two_by_two, four_solutions,
               "2x2 candidates gives 4 solutions");

    destroy_solution_matrix(four_solutions);
    destroy_dlx_matrix(two_by_two);
}

void test_same_rows_in_different_order() {
    dlx_matrix *different_order = create_dlx_matrix();
    struct dlx_matrix_row *dlx_row;
    solution_matrix *four_solutions = create_solution_matrix();
    struct solution_matrix_row *solution;

    dlx_row = add_dlx_row(different_order);
    add_dlx_value(dlx_row, 0);
    dlx_row = add_dlx_row(different_order);
    add_dlx_value(dlx_row, 1);
    dlx_row = add_dlx_row(different_order);
    add_dlx_value(dlx_row, 0);
    dlx_row = add_dlx_row(different_order);
    add_dlx_value(dlx_row, 1);

    solution = add_solution(four_solutions);
    add_solution_value(solution, 0);
    add_solution_value(solution, 1);
    solution = add_solution(four_solutions);
    add_solution_value(solution, 0);
    add_solution_value(solution, 3);
    solution = add_solution(four_solutions);
    add_solution_value(solution, 2);
    add_solution_value(solution, 1);
    solution = add_solution(four_solutions);
    add_solution_value(solution, 2);
    add_solution_value(solution, 3);

    test_solve(different_order, four_solutions, "same rows in different order");

    destroy_solution_matrix(four_solutions);
    destroy_dlx_matrix(different_order);
}

void test_only_one_solution() {
    dlx_matrix *two_lines = create_dlx_matrix();
    struct dlx_matrix_row *dlx_row;
    solution_matrix *one_solution = create_solution_matrix();
    struct solution_matrix_row *solution;

    dlx_row = add_dlx_row(two_lines);
    add_dlx_value(dlx_row, 0);
    add_dlx_value(dlx_row, 2);
    dlx_row = add_dlx_row(two_lines);
    add_dlx_value(dlx_row, 1);
    add_dlx_value(dlx_row, 3);

    solution = add_solution(one_solution);
    add_solution_value(solution, 0);
    add_solution_value(solution, 1);

    test_solve(two_lines, one_solution, "only one solution");

    destroy_solution_matrix(one_solution);
    destroy_dlx_matrix(two_lines);
}

void test_knuths_example() {
    dlx_matrix *knuths_input = create_dlx_matrix();
    struct dlx_matrix_row *dlx_row;
    solution_matrix *solutions = create_solution_matrix();
    struct solution_matrix_row *solution;

    dlx_row = add_dlx_row(knuths_input);
    add_dlx_value(dlx_row, 2);
    add_dlx_value(dlx_row, 4);
    add_dlx_value(dlx_row, 5);
    dlx_row = add_dlx_row(knuths_input);
    add_dlx_value(dlx_row, 0);
    add_dlx_value(dlx_row, 3);
    add_dlx_value(dlx_row, 6);
    dlx_row = add_dlx_row(knuths_input);
    add_dlx_value(dlx_row, 1);
    add_dlx_value(dlx_row, 2);
    add_dlx_value(dlx_row, 5);
    dlx_row = add_dlx_row(knuths_input);
    add_dlx_value(dlx_row, 0);
    add_dlx_value(dlx_row, 3);
    dlx_row = add_dlx_row(knuths_input);
    add_dlx_value(dlx_row, 1);
    add_dlx_value(dlx_row, 6);
    dlx_row = add_dlx_row(knuths_input);
    add_dlx_value(dlx_row, 3);
    add_dlx_value(dlx_row, 4);
    add_dlx_value(dlx_row, 6);

    solution = add_solution(solutions);
    add_solution_value(solution, 3);
    add_solution_value(solution, 4);
    add_solution_value(solution, 0);

    test_solve(knuths_input, solutions, "Knuth's example");

    destroy_solution_matrix(solutions);
    destroy_dlx_matrix(knuths_input);
}

int main(int argc, char **argv) {
    test_that_empty_matrix_gives_one_solution();
    test_that_identity_matrix_gives_all_lines();
    test_that_2_by_2_candidates_gives_4_solutions();
    test_same_rows_in_different_order();
    test_only_one_solution();
    test_knuths_example();

    return EXIT_SUCCESS;
}
