#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dancing-links.h"

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

int height(dlx_matrix *matrix) {
    int h = 0;
    struct dlx_matrix_row *row = matrix->first_row;

    while (row != NULL) {
        h++;
        row = row->next_row;
    }
    return h;
}

struct data_header *create_data_header() {
    struct data_header *new_data_header = malloc(sizeof (struct data_header));
    struct data_object *new_data_header_do = (struct data_object *)new_data_header;
    new_data_header_do->L = new_data_header_do;
    new_data_header_do->R = new_data_header_do;
    new_data_header_do->U = new_data_header_do;
    new_data_header_do->D = new_data_header_do;
    new_data_header->S = 0;
    return new_data_header;
}

void increase_S(struct data_header *header) {
    header->S++;
}

void decrease_S(struct data_header *header) {
    header->S--;
}

struct data_node *create_data_node(int row, struct data_header *header) {
    struct data_node *new_data_node = malloc(sizeof (struct data_node));
    struct data_object *new_data_node_do = (struct data_object *)new_data_node;
    new_data_node_do->L = new_data_node_do;
    new_data_node_do->R = new_data_node_do;
    new_data_node_do->U = new_data_node_do;
    new_data_node_do->D = new_data_node_do;
    new_data_node->row = row;
    new_data_node->C = header;
    increase_S(header);
    return new_data_node;
}

void attach_below(struct data_object *self, struct data_object *other) {
    other->D->U = self;
    self->D = other->D;
    self->U = other;
    other->D = self;
}

void attach_to_right_of(struct data_object *self, struct data_object *other) {
    other->R->L = self;
    self->R = other->R;
    self->L = other;
    other->R = self;
}

void attach_to_left_of(struct data_object *self, struct data_object *other) {
    attach_to_right_of(other, self);
}

struct data_header *linked_representation(dlx_matrix *matrix) {
    int w = width(matrix);
    int h = height(matrix);
    struct data_header *root = create_data_header();
    struct data_header *last_seen_header = root;
    struct data_node **last_seen_on_row
        = calloc(h, sizeof(struct data_node*));
    int i;

    for (i = 0; i < w; i++) {
        struct data_header *header = create_data_header();
        struct data_object *last_seen_node = (struct data_object *)header;
        struct dlx_matrix_row *current_row;
        int j = 0;
        attach_to_right_of((struct data_object *)header,
                           (struct data_object*)last_seen_header);
        last_seen_header = header;

        current_row = matrix->first_row;
        while (current_row != NULL) {
            if (dlx_row_contains_value(current_row, i)) {
                struct data_node *data_node = create_data_node(j, header);
                attach_below((struct data_object *)data_node, last_seen_node);
                last_seen_node = (struct data_object *)data_node;

                if (last_seen_on_row[j] != NULL) {
                    attach_to_right_of(
                        (struct data_object *)data_node,
                        (struct data_object *)last_seen_on_row[j]
                    );
                }
                last_seen_on_row[j] = data_node;
            }

            current_row = current_row->next_row;
            j++;
        }
    }
    free(last_seen_on_row);
    return root;
}

struct data_header *choose_column(struct data_header *root) {
    struct data_object *rdo = (struct data_object *)root;
    struct data_object *column;
    struct data_object *column_with_minimal_ones;
    int minimal_ones = 32767;   /* (infinity) */
    for (column = rdo->R; column != rdo; column = column->R) {
        if (minimal_ones > ((struct data_header *)column)->S) {
            minimal_ones = ((struct data_header *)column)->S;
            column_with_minimal_ones = column;
        }
    }
    return (struct data_header *)column_with_minimal_ones;
}

void cover_column(struct data_header *c) {
    struct data_object *i, *j;
    struct data_object *cdo = (struct data_object *)c;
    cdo->R->L = cdo->L;
    cdo->L->R = cdo->R;
    for (i = cdo->D; i != cdo; i = i->D) {
        for (j = i->R; j != i; j = j->R) {
            j->D->U = j->U;
            j->U->D = j->D;
            decrease_S(((struct data_node *)j)->C);
        }
    }
}

void uncover_column(struct data_header *c) {
    struct data_object *i, *j;
    struct data_object *cdo = (struct data_object *)c;
    for (i = cdo->U; i != cdo; i = i->U) {
        for (j = i->L; j != i; j = j->L) {
            increase_S(((struct data_node *)j)->C);
            j->D->U = j;
            j->U->D = j;
        }
    }
    cdo->R->L = cdo;
    cdo->L->R = cdo;
}

long solutions;

void solve_dancing_links_helper(struct data_header *root) {

    if (((struct data_object *)root)->R == (struct data_object *)root) {
        solutions++;
        if (solutions % 1000000L == 0) {
            printf("%ld\n", solutions);
        }
    }
    else {
        struct data_header *c = choose_column(root);
        struct data_object *cdo = (struct data_object *)c;
        struct data_object *r;
        cover_column(c);
        for (r = cdo->D; r != cdo; r = r->D) {
            struct data_object *j;
            for (j = r->R; j != r; j = j->R) {
                cover_column(((struct data_node *)j)->C);
            }

            solve_dancing_links_helper(root);

            for (j = r->L; j != r; j = j->L) {
                uncover_column(((struct data_node *)j)->C);
            }
        }
        uncover_column(c);
    }
}

long solve_dancing_links(dlx_matrix *dlx_matrix) {
    solutions = 0;
    struct data_header *root;

    root = linked_representation(dlx_matrix);

    solve_dancing_links_helper(root);

    /* need to destroy the linked representation here */
    return solutions;
}
