#ifndef C_SYMENGINE_BRIDGE_H
#define C_SYMENGINE_BRIDGE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void *se_basic_t;

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

void se_basic_const_pi(se_basic_t result);
void se_basic_const_e(se_basic_t result);
int32_t se_basic_eq(se_basic_t lhs, se_basic_t rhs);

#ifdef __cplusplus
}
#endif

#endif
