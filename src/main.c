#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define FILENAME "samplefile.sfz"

#include "region.h"

void parse(char *content) {
    int length = strlen(content);
    for (int i = 0; i < length; i++) {
        printf("STRING: %s\n", &content[i]);
    }
}

int main() {
    char linebuffer[512];
    char *content = malloc(1);
    FILE *filestream = fopen(FILENAME, "r");

    while (fgets(linebuffer, sizeof(linebuffer), filestream)) {
        content = realloc(content, strlen(content) + strlen(linebuffer) + 1);
        strcat(content, linebuffer);
    }

    parse(content);

    fclose(filestream);
    free(content);

    return 0;
}

