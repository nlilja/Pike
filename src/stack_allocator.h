/*
|| This file is part of Pike. For copyright information see COPYRIGHT.
|| Pike is distributed under GPL, LGPL and MPL. See the file COPYING
|| for more information.
*/

#include "global.h"
#include "pike_memory.h"

struct stack_allocator {
    struct chunk * cur;
    size_t initial;
};

struct chunk {
    struct chunk * prev;
    void * data, * top;
    size_t size;
};

void stack_alloc_enlarge(struct stack_allocator * a, size_t size);
void stack_alloc_destroy(struct stack_allocator * a);

static void PIKE_UNUSED_ATTRIBUTE stack_alloc_init(struct stack_allocator * a, size_t initial) {
    a->cur = NULL;
    a->initial = initial;
}

static size_t sa_left(const struct chunk * c) {
    return (size_t)(((char*)c->data + c->size) - (char*)c->top);
}

static void sa_alloc_enlarge(struct stack_allocator * a, size_t size) {
    struct chunk * c = a->cur;

    if (!c || sa_left(c) < size)
        stack_alloc_enlarge(a, size);
}

MALLOC_FUNCTION
static void * sa_alloc_fast(struct stack_allocator * a, size_t size) {
    struct chunk * c = a->cur;
    void * ret = c->top;
    c->top = (char*)c->top + size;
    return ret;
}

MALLOC_FUNCTION
static void PIKE_UNUSED_ATTRIBUTE * sa_alloc(struct stack_allocator * a, size_t size) {
    sa_alloc_enlarge(a, size);
    return sa_alloc_fast(a, size);
}
