#ifndef REGION_H
#define REGION_H

typedef struct Region {
    char sample[512];

    char key[3];
    char lokey[3];
    char hikey[3];
    int lovel;
    int hivel;

    char pitch_keycenter[3];
    char loop_mode[16];
} Region;

#endif
