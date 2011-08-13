#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int test_number = 0;

struct dlx_matrix_value {
    struct dlx_matrix_value *next_value;
    int value;
};

struct dlx_matrix_row {
    struct dlx_matrix_row *next_row;
    struct dlx_matrix_value *first_value;
};

typedef struct {
    struct dlx_matrix_row *first_row;
} dlx_matrix;

struct solution_matrix_value {
    struct solution_matrix_value *next_value;
    int value;
};

struct solution_matrix_row {
    struct solution_matrix_row *next_row;
    struct solution_matrix_value *first_value;
};

typedef struct {
    struct solution_matrix_row *first_row;
} solution_matrix;

struct rows_stack_element {
    struct rows_stack_element* next;
    int value;
};

typedef struct {
    struct rows_stack_element* top;
} rows_stack;

dlx_matrix *create_dlx_matrix() {
    dlx_matrix *new_matrix;

    new_matrix = malloc(sizeof (dlx_matrix));
    new_matrix->first_row = NULL;

    return new_matrix;
}

void destroy_dlx_matrix_values(struct dlx_matrix_value *value) {
    if (value == NULL) {
        return;
    }
    destroy_dlx_matrix_values(value->next_value);
    free(value);
}

void destroy_dlx_matrix_rows(struct dlx_matrix_row *row) {
    if (row == NULL) {
        return;
    }
    destroy_dlx_matrix_rows(row->next_row);
    destroy_dlx_matrix_values(row->first_value);
    free(row);
}

void destroy_dlx_matrix(dlx_matrix *matrix) {
    destroy_dlx_matrix_rows(matrix->first_row);
    free(matrix);
}

struct dlx_matrix_row *add_dlx_row(dlx_matrix *matrix) {
    struct dlx_matrix_row *new_row
        = malloc(sizeof (struct dlx_matrix_row));
    new_row->first_value = NULL;
    new_row->next_row = NULL;

    if (matrix->first_row == NULL) {
        matrix->first_row = new_row;
    }
    else {
        struct dlx_matrix_row *matrix_row = matrix->first_row;
        while (matrix_row->next_row != NULL) {
            matrix_row = matrix_row->next_row;
        }
        matrix_row->next_row = new_row;
    }

    return new_row;
}

void add_dlx_value(struct dlx_matrix_row *row, int value) {
    struct dlx_matrix_value *new_value
        = malloc(sizeof (struct dlx_matrix_value));
    new_value->next_value = NULL;
    new_value->value = value;

    if (row->first_value == NULL) {
        row->first_value = new_value;
    }
    else {
        struct dlx_matrix_value *matrix_value = row->first_value;
        while (matrix_value->next_value != NULL) {
            matrix_value = matrix_value->next_value;
        }
        matrix_value->next_value = new_value;
    }
}

int dlx_row_contains_value(struct dlx_matrix_row *row, int value) {
    struct dlx_matrix_value *matrix_value = row->first_value;
    while (matrix_value != NULL) {
        if (value == matrix_value->value) {
            return 1;
        }
        matrix_value = matrix_value->next_value;
    }
    return 0;
}

solution_matrix *create_solution_matrix() {
    solution_matrix *new_matrix;

    new_matrix = malloc(sizeof (solution_matrix));
    new_matrix->first_row = NULL;

    return new_matrix;
}

void destroy_solution_matrix_values(struct solution_matrix_value *value) {
    if (value == NULL) {
        return;
    }
    destroy_solution_matrix_values(value->next_value);
    free(value);
}

void destroy_solution_matrix_rows(struct solution_matrix_row *row) {
    if (row == NULL) {
        return;
    }
    destroy_solution_matrix_rows(row->next_row);
    destroy_solution_matrix_values(row->first_value);
    free(row);
}

void destroy_solution_matrix(solution_matrix *matrix) {
    destroy_solution_matrix_rows(matrix->first_row);
    free(matrix);
}

struct solution_matrix_row *add_solution(solution_matrix *matrix) {
    struct solution_matrix_row *new_row
        = malloc(sizeof (struct solution_matrix_row));
    new_row->first_value = NULL;
    new_row->next_row = NULL;

    if (matrix->first_row == NULL) {
        matrix->first_row = new_row;
    }
    else {
        struct solution_matrix_row *matrix_row = matrix->first_row;
        while (matrix_row->next_row != NULL) {
            matrix_row = matrix_row->next_row;
        }
        matrix_row->next_row = new_row;
    }

    return new_row;
}

void add_solution_value(struct solution_matrix_row *row, int value) {
    struct solution_matrix_value *new_value
        = malloc(sizeof (struct solution_matrix_value));
    new_value->next_value = NULL;
    new_value->value = value;

    if (row->first_value == NULL) {
        row->first_value = new_value;
    }
    else {
        struct solution_matrix_value *matrix_value = row->first_value;
        while (matrix_value->next_value != NULL) {
            matrix_value = matrix_value->next_value;
        }
        matrix_value->next_value = new_value;
    }
}

void add_solution_values_from_stack_helper(
    struct solution_matrix_row *solution,
    struct rows_stack_element *elem) {

    if (elem == NULL) {
        return;
    }
    add_solution_values_from_stack_helper(solution, elem->next);
    add_solution_value(solution, elem->value);
}

void add_solution_values_from_stack(struct solution_matrix_row *solution,
                                    rows_stack *stack) {
    struct rows_stack_element *elem = stack->top;
    add_solution_values_from_stack_helper(solution, elem);
}

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

int width(dlx_matrix *matrix) {
    int max = -1;
    struct dlx_matrix_row *row = matrix->first_row;

    while (row != NULL) {
        struct dlx_matrix_value *value = row->first_value;
        while (value != NULL) {
            if (max < value->value) {
                max = value->value;
            }
            value = value->next_value;
        }
        row = row->next_row;
    }
    return max + 1;
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

rows_stack *create_rows_stack() {
    rows_stack *new_stack = malloc(sizeof (rows_stack));
    new_stack->top = NULL;
    return new_stack;
}

void rows_push(rows_stack *stack, int value) {
    struct rows_stack_element *new_top
        = malloc(sizeof (struct rows_stack_element));
    new_top->next = stack->top;
    new_top->value = value;
    stack->top = new_top;
}

void rows_pop(rows_stack *stack) {
    struct rows_stack_element *old_top = stack->top;
    stack->top = old_top->next;
    free(old_top);
}

void destroy_rows_stack(rows_stack *stack) {
    while (stack->top != NULL) {
        rows_pop(stack);
    }
    free(stack);
}

void search_dancing_links(dlx_matrix *dlx_matrix, solution_matrix *solutions,
                          int column, rows_stack *rows_stack) {
    if (column >= width(dlx_matrix)) {
        struct solution_matrix_row *solution = add_solution(solutions);
        add_solution_values_from_stack(solution, rows_stack);
    }
    else {
        struct dlx_matrix_row *row = dlx_matrix->first_row;
        int row_number = 0;
        while (row != NULL) {
            if (dlx_row_contains_value(row, column)) {
                rows_push(rows_stack, row_number);
                search_dancing_links(dlx_matrix, solutions, column + 1,
                                     rows_stack);
                rows_pop(rows_stack);
            }
            row_number++;
            row = row->next_row;
        }
    }
}

solution_matrix *solve_dancing_links(dlx_matrix *dlx_matrix) {
    solution_matrix *solutions = create_solution_matrix();
    rows_stack *stack = create_rows_stack();

    search_dancing_links(dlx_matrix, solutions, 0, stack);

    destroy_rows_stack(stack);
    return solutions;
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
               "identity matrix gives all lines");

    destroy_solution_matrix(four_solutions);
    destroy_dlx_matrix(two_by_two);
}

int main(int argc, char **argv) {
    test_that_empty_matrix_gives_one_solution();
    test_that_identity_matrix_gives_all_lines();
    test_that_2_by_2_candidates_gives_4_solutions();

    return EXIT_SUCCESS;
}
