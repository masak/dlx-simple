#ifndef DANCING_LINKS_H_GUARD
#define DANCING_LINKS_H_GUARD

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

struct data_object {
    struct data_object *L, *R, *U, *D;
};

struct data_header {
    struct data_object data_object;
    int S;
};

struct data_node {
    struct data_object data_object;
    struct data_header *C;
    int row;
};

dlx_matrix *create_dlx_matrix();
int width(dlx_matrix *);
int height(dlx_matrix *);
void destroy_dlx_matrix(dlx_matrix *);

struct dlx_matrix_row *add_dlx_row(dlx_matrix *);
int dlx_row_contains_value(struct dlx_matrix_row *, int);
void destroy_dlx_matrix_rows(struct dlx_matrix_row *);

void add_dlx_value(struct dlx_matrix_row *, int);
void destroy_dlx_matrix_values(struct dlx_matrix_value *);

solution_matrix *create_solution_matrix();
void destroy_solution_matrix(solution_matrix *);

struct solution_matrix_row *add_solution(solution_matrix *);
char *contents(struct solution_matrix_row *);
void destroy_solution_matrix_rows(struct solution_matrix_row *);

void add_solution_value(struct solution_matrix_row *, int);
void destroy_solution_matrix_values(struct solution_matrix_value *);

void add_solution_values_from_stack(struct solution_matrix_row *,
                                    rows_stack *);
void add_solution_values_from_stack_helper(struct solution_matrix_row *,
                                           struct rows_stack_element *);

rows_stack *create_rows_stack();
void rows_push(rows_stack *, int);
void rows_pop(rows_stack *);
void destroy_rows_stack(rows_stack *);

struct data_header *create_data_header();
void increase_S(struct data_header *);
void decrease_S(struct data_header *);

struct data_node *create_data_node(int, struct data_header *);

void attach_below(struct data_object *, struct data_object *);
void attach_to_right_of(struct data_object *, struct data_object *);
void attach_to_left_of(struct data_object *, struct data_object *);

struct data_header *linked_representation(dlx_matrix *);
struct data_header *choose_column(struct data_header *);

void cover_column(struct data_header *);
void uncover_column(struct data_header *);

void solve_dancing_links_helper(
    struct data_header *,
    rows_stack *,
    solution_matrix *);
solution_matrix *solve_dancing_links(dlx_matrix *);

#endif
