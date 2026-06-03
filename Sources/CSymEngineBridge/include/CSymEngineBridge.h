#ifndef C_SYMENGINE_BRIDGE_H
#define C_SYMENGINE_BRIDGE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void *se_basic_t;
typedef void *se_basic_map_t;
typedef void *se_basic_set_t;

se_basic_t se_basic_new(void);
void se_basic_free(se_basic_t value);
int32_t se_basic_assign(se_basic_t target, se_basic_t source);

int32_t se_basic_parse(se_basic_t target, const char *text);
char *se_basic_str(se_basic_t value);
void se_string_free(char *text);

int32_t se_integer_set_si(se_basic_t target, long value);
int32_t se_rational_set_si(se_basic_t target, long numerator, long denominator);
int32_t se_real_double_set_d(se_basic_t target, double value);
int32_t se_symbol_set(se_basic_t target, const char *name);

int32_t se_basic_add(se_basic_t result, se_basic_t lhs, se_basic_t rhs);
int32_t se_basic_sub(se_basic_t result, se_basic_t lhs, se_basic_t rhs);
int32_t se_basic_mul(se_basic_t result, se_basic_t lhs, se_basic_t rhs);
int32_t se_basic_div(se_basic_t result, se_basic_t lhs, se_basic_t rhs);
int32_t se_basic_pow(se_basic_t result, se_basic_t lhs, se_basic_t rhs);
int32_t se_basic_diff(se_basic_t result, se_basic_t expr, se_basic_t symbol);
int32_t se_basic_expand(se_basic_t result, se_basic_t value);
int32_t se_basic_neg(se_basic_t result, se_basic_t value);
int32_t se_basic_abs(se_basic_t result, se_basic_t value);
int32_t se_basic_sin(se_basic_t result, se_basic_t value);
int32_t se_basic_cos(se_basic_t result, se_basic_t value);
int32_t se_basic_tan(se_basic_t result, se_basic_t value);
int32_t se_basic_asin(se_basic_t result, se_basic_t value);
int32_t se_basic_acos(se_basic_t result, se_basic_t value);
int32_t se_basic_atan(se_basic_t result, se_basic_t value);
int32_t se_basic_sinh(se_basic_t result, se_basic_t value);
int32_t se_basic_cosh(se_basic_t result, se_basic_t value);
int32_t se_basic_tanh(se_basic_t result, se_basic_t value);
int32_t se_basic_exp(se_basic_t result, se_basic_t value);
int32_t se_basic_log(se_basic_t result, se_basic_t value);
int32_t se_basic_sqrt(se_basic_t result, se_basic_t value);
int32_t se_basic_evalf(se_basic_t result, se_basic_t value, unsigned long bits, int32_t real);

void se_basic_const_pi(se_basic_t result);
void se_basic_const_e(se_basic_t result);
int32_t se_basic_eq(se_basic_t lhs, se_basic_t rhs);
int32_t se_basic_is_integer(se_basic_t value);
int32_t se_basic_is_real_double(se_basic_t value);
long se_integer_get_si(se_basic_t value);
double se_real_double_get_d(se_basic_t value);

se_basic_map_t se_basic_map_new(void);
void se_basic_map_free(se_basic_map_t value);
void se_basic_map_insert(se_basic_map_t map, se_basic_t key, se_basic_t mapped);
int32_t se_basic_subs_map(se_basic_t result, se_basic_t expr, se_basic_map_t substitutions);
int32_t se_basic_subs_pair(se_basic_t result, se_basic_t expr, se_basic_t lhs, se_basic_t rhs);

se_basic_set_t se_basic_set_new(void);
void se_basic_set_free(se_basic_set_t value);
int32_t se_basic_free_symbols(se_basic_t expr, se_basic_set_t symbols);
int32_t se_basic_set_size(se_basic_set_t value);
int32_t se_basic_set_get(se_basic_set_t value, int32_t index, se_basic_t out_value);

#ifdef __cplusplus
}
#endif

#endif
