#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define COMMAND_SIZE 128
#define OUTPUT_SIZE 10

int main() {
    char layout[COMMAND_SIZE];
    char command[COMMAND_SIZE];
    FILE *fp;

    // Fetch the current layout name from AwesomeWM
    snprintf(command, sizeof(command), "awesome-client 'local awful = require(\"awful\"); return awful.layout.get(awful.screen.focused()).name'");
    fp = popen(command, "r");
    if (fp == NULL) {
        perror("popen");
        return 1;
    }

    if (fgets(layout, sizeof(layout), fp) == NULL) {
        perror("fgets");
        pclose(fp);
        return 1;
    }
    pclose(fp);

    // Extract layout name without 'string ' prefix and extra quotes
    char *start = strchr(layout, '"');
    char *end = strrchr(layout, '"');
    if (start != NULL && end != NULL && start != end) {
        start++;
        *end = '\0';
        strncpy(layout, start, sizeof(layout));
        layout[sizeof(layout) - 1] = '\0';
    } else {
        printf("??\n");
        return 1;
    }

    // Determine the output based on the layout
    char output[OUTPUT_SIZE];
    if (strcmp(layout, "tile") == 0) {
        snprintf(output, sizeof(output), " ");
    } else if (strcmp(layout, "tilebottom") == 0) {
        snprintf(output, sizeof(output), " ");
    } else if (strcmp(layout, "dwindle") == 0) {
        snprintf(output, sizeof(output), " ");
    } else if (strcmp(layout, "floating") == 0) {
        snprintf(output, sizeof(output), "󱂬 ");
    } else {
        snprintf(output, sizeof(output), "??");
    }

    // Output the result
    printf("%s\n", output);

    return 0;
}
