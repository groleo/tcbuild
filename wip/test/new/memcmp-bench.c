#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/times.h>

#define MEMSZ (5*1024*1024)
#define LISTSZ (4)
void* list[LISTSZ];

int main(void)
{
    int count = sizeof(list) / sizeof(char*);
    int i;
    for (i=0; i < count; i++)
        list[i] = calloc(MEMSZ, sizeof(char) );

    int dupes = 0;
    int start = times(NULL);

    for (i=0; i<count-1; i++)
        if (!memcmp(list[i], list[i+1], MEMSZ))
            dupes++;

    int ticks = times(NULL) - start;
    printf("Time: %d ticks (%d tick/memcmp)(%d dupes)\n", ticks, ticks/dupes, dupes);

    return 0;
}

