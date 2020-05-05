#ifndef SIMULATOR_CYIS_H
#define SIMULATOR_CYIS_H

#include "isa.h"
#include <stdlib.h>

int calculate_len(int len);

int run_yis(const char *yo_path, stat_t *ep, state_rec *sp);

#endif  // SIMULATOR_CYIS_H
