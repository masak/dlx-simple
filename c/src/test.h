#ifndef TEST_H
#define TEST_H

int test_number = 0;

int rows_are_equal(struct solution_matrix_row *,
                   struct solution_matrix_row *);
void output_eqv(solution_matrix *, solution_matrix *, char *);
void test_solve(dlx_matrix *, solution_matrix *, char *);

void test_that_empty_matrix_gives_one_solution();
void test_that_identity_matrix_gives_all_lines();
void test_that_2_by_2_candidates_gives_4_solutions();
void test_same_rows_in_different_order();
void test_only_one_solution();
void test_knuths_example();

int main(int argc, char **argv);

#endif
