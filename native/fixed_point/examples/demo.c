#include <stdio.h>
#include "../include/macrogrok_fixed.h"

int main(void) {
    int16_t state;
    int32_t score;
    uint16_t flags;

    macrogrok_reset_state();

    int16_t inputs[][4] = {
        {16384, 0, 0, 0},
        {0, 16384, 0, 0},
        {-16384, -16384, 0, 0},
        {8192, 8192, 8192, 8192}
    };

    for (int i = 0; i < 4; i++) {
        int rc = macrogrok_infer4(
            inputs[i][0], inputs[i][1], inputs[i][2], inputs[i][3],
            &state, &score, &flags);

        if (rc != 0) {
            printf("error\n");
            continue;
        }

        printf("in=[%.3f, %.3f, %.3f, %.3f] -> "
               "score=%d (%.3f) state=%d (%.3f) flags=%03x\n",
               inputs[i][0] / 16384.0f,
               inputs[i][1] / 16384.0f,
               inputs[i][2] / 16384.0f,
               inputs[i][3] / 16384.0f,
               score, score / 4096.0f,
               state, state / 16384.0f,
               flags);
    }

    return 0;
}
