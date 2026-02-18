#include "CSymEngineBridge.h"

#include <stdlib.h>
#include <string.h>

#include "symengine/cwrapper.h"

static inline basic_struct *to_basic(se_basic_t value)
{
    return (basic_struct *)value;
}

se_basic_t se_basic_new(void)
{
    return (se_basic_t)basic_new_heap();
}

void se_basic_free(se_basic_t value)
{
    if (value != NULL) {
        basic_free_heap(to_basic(value));
    }
}

int32_t se_basic_assign(se_basic_t target, se_basic_t source)
{
    return (int32_t)basic_assign(to_basic(target), to_basic(source));
}

int32_t se_basic_parse(se_basic_t target, const char *text)
{
    return (int32_t)basic_parse(to_basic(target), text);
}

char *se_basic_str(se_basic_t value)
{
    char *raw = basic_str(to_basic(value));
    if (raw == NULL) {
        return NULL;
    }
    size_t length = strlen(raw);
    char *copy = (char *)malloc(length + 1);
    if (copy == NULL) {
        basic_str_free(raw);
        return NULL;
    }
    memcpy(copy, raw, length + 1);
    basic_str_free(raw);
    return copy;
}

void se_string_free(char *text)
{
    free(text);
}

int32_t se_integer_set_si(se_basic_t target, long value)
{
    return (int32_t)integer_set_si(to_basic(target), value);
}

int32_t se_rational_set_si(se_basic_t target, long numerator, long denominator)
{
    return (int32_t)rational_set_si(to_basic(target), numerator, denominator);
}

int32_t se_real_double_set_d(se_basic_t target, double value)
{
    return (int32_t)real_double_set_d(to_basic(target), value);
}

int32_t se_symbol_set(se_basic_t target, const char *name)
{
    return (int32_t)symbol_set(to_basic(target), name);
}

int32_t se_basic_add(se_basic_t result, se_basic_t lhs, se_basic_t rhs)
{
    return (int32_t)basic_add(to_basic(result), to_basic(lhs), to_basic(rhs));
}

int32_t se_basic_sub(se_basic_t result, se_basic_t lhs, se_basic_t rhs)
{
    return (int32_t)basic_sub(to_basic(result), to_basic(lhs), to_basic(rhs));
}

int32_t se_basic_mul(se_basic_t result, se_basic_t lhs, se_basic_t rhs)
{
    return (int32_t)basic_mul(to_basic(result), to_basic(lhs), to_basic(rhs));
}

int32_t se_basic_div(se_basic_t result, se_basic_t lhs, se_basic_t rhs)
{
    return (int32_t)basic_div(to_basic(result), to_basic(lhs), to_basic(rhs));
}

int32_t se_basic_pow(se_basic_t result, se_basic_t lhs, se_basic_t rhs)
{
    return (int32_t)basic_pow(to_basic(result), to_basic(lhs), to_basic(rhs));
}

void se_basic_const_pi(se_basic_t result)
{
    basic_const_pi(to_basic(result));
}

void se_basic_const_e(se_basic_t result)
{
    basic_const_E(to_basic(result));
}

int32_t se_basic_eq(se_basic_t lhs, se_basic_t rhs)
{
    return (int32_t)basic_eq(to_basic(lhs), to_basic(rhs));
}
