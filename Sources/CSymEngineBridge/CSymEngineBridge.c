#include "CSymEngineBridge.h"

#include <stdlib.h>
#include <string.h>

#include "symengine/cwrapper.h"

static inline basic_struct *to_basic(se_basic_t value)
{
    return (basic_struct *)value;
}

static inline CMapBasicBasic *to_basic_map(se_basic_map_t value)
{
    return (CMapBasicBasic *)value;
}

static inline CSetBasic *to_basic_set(se_basic_set_t value)
{
    return (CSetBasic *)value;
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

int32_t se_basic_diff(se_basic_t result, se_basic_t expr, se_basic_t symbol)
{
    return (int32_t)basic_diff(to_basic(result), to_basic(expr), to_basic(symbol));
}

int32_t se_basic_expand(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_expand(to_basic(result), to_basic(value));
}

int32_t se_basic_neg(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_neg(to_basic(result), to_basic(value));
}

int32_t se_basic_abs(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_abs(to_basic(result), to_basic(value));
}

int32_t se_basic_sin(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_sin(to_basic(result), to_basic(value));
}

int32_t se_basic_cos(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_cos(to_basic(result), to_basic(value));
}

int32_t se_basic_tan(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_tan(to_basic(result), to_basic(value));
}

int32_t se_basic_asin(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_asin(to_basic(result), to_basic(value));
}

int32_t se_basic_acos(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_acos(to_basic(result), to_basic(value));
}

int32_t se_basic_atan(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_atan(to_basic(result), to_basic(value));
}

int32_t se_basic_sinh(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_sinh(to_basic(result), to_basic(value));
}

int32_t se_basic_cosh(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_cosh(to_basic(result), to_basic(value));
}

int32_t se_basic_tanh(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_tanh(to_basic(result), to_basic(value));
}

int32_t se_basic_exp(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_exp(to_basic(result), to_basic(value));
}

int32_t se_basic_log(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_log(to_basic(result), to_basic(value));
}

int32_t se_basic_sqrt(se_basic_t result, se_basic_t value)
{
    return (int32_t)basic_sqrt(to_basic(result), to_basic(value));
}

int32_t se_basic_evalf(se_basic_t result, se_basic_t value, unsigned long bits, int32_t real)
{
    return (int32_t)basic_evalf(to_basic(result), to_basic(value), bits, real);
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

int32_t se_basic_is_integer(se_basic_t value)
{
    return (int32_t)is_a_Integer(to_basic(value));
}

int32_t se_basic_is_real_double(se_basic_t value)
{
    return (int32_t)is_a_RealDouble(to_basic(value));
}

long se_integer_get_si(se_basic_t value)
{
    return integer_get_si(to_basic(value));
}

double se_real_double_get_d(se_basic_t value)
{
    return real_double_get_d(to_basic(value));
}

se_basic_map_t se_basic_map_new(void)
{
    return (se_basic_map_t)mapbasicbasic_new();
}

void se_basic_map_free(se_basic_map_t value)
{
    if (value != NULL) {
        mapbasicbasic_free(to_basic_map(value));
    }
}

void se_basic_map_insert(se_basic_map_t map, se_basic_t key, se_basic_t mapped)
{
    mapbasicbasic_insert(to_basic_map(map), to_basic(key), to_basic(mapped));
}

int32_t se_basic_subs_map(se_basic_t result, se_basic_t expr, se_basic_map_t substitutions)
{
    return (int32_t)basic_subs(to_basic(result), to_basic(expr), to_basic_map(substitutions));
}

int32_t se_basic_subs_pair(se_basic_t result, se_basic_t expr, se_basic_t lhs, se_basic_t rhs)
{
    return (int32_t)basic_subs2(to_basic(result), to_basic(expr), to_basic(lhs), to_basic(rhs));
}

se_basic_set_t se_basic_set_new(void)
{
    return (se_basic_set_t)setbasic_new();
}

void se_basic_set_free(se_basic_set_t value)
{
    if (value != NULL) {
        setbasic_free(to_basic_set(value));
    }
}

int32_t se_basic_free_symbols(se_basic_t expr, se_basic_set_t symbols)
{
    return (int32_t)basic_free_symbols(to_basic(expr), to_basic_set(symbols));
}

int32_t se_basic_set_size(se_basic_set_t value)
{
    return (int32_t)setbasic_size(to_basic_set(value));
}

int32_t se_basic_set_get(se_basic_set_t value, int32_t index, se_basic_t out_value)
{
    if (value == NULL || out_value == NULL || index < 0) {
        return -1;
    }

    size_t size = setbasic_size(to_basic_set(value));
    if ((size_t)index >= size) {
        return -1;
    }

    setbasic_get(to_basic_set(value), index, to_basic(out_value));
    return 0;
}
