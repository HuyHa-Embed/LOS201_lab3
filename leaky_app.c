#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef MEMSTAT
#include <unistd.h>
/* Doc VmSize/VmRSS cua chinh process (B.5: do bo nho tren target QEMU) */
static void memstat(const char *tag) {
    char line[128];
    FILE *f = fopen("/proc/self/status", "r");
    if (!f) return;
    while (fgets(line, sizeof line, f))
        if (!strncmp(line, "VmSize", 6) || !strncmp(line, "VmRSS", 5))
            printf("  [%s] %s", tag, line);
    fclose(f);
}
#else
#define memstat(tag) ((void)0)
#endif

#define NUM_RECORDS  100
#define MSG_SIZE     256

typedef struct {
    int  id;
    char *name;     /* Heap allocated - de bi quen free */
    int  *scores;   /* Heap allocated - de bi quen free */
} Record;

Record *create_record(int id, const char *name, int num_scores) {
    Record *r = malloc(sizeof(Record));
    r->id     = id;
    r->name   = malloc(strlen(name) + 1);
    strcpy(r->name, name);
    r->scores = malloc(sizeof(int) * num_scores);
    for (int i = 0; i < num_scores; i++)
        r->scores[i] = id * 10 + i;
    return r;
}

/* Leak 1: free record nhung QUEN free r->name va r->scores */
void delete_record(Record *r) {
#ifdef FIXED
    free(r->name);
    free(r->scores);
#endif
    free(r);
}

/* Leak 2: buffer trong vong lap khong duoc free */
void process_messages(int count) {
    for (int i = 0; i < count; i++) {
        char *buf = malloc(MSG_SIZE);
        snprintf(buf, MSG_SIZE, "Message #%d: data payload here", i);
        if (i % 10 == 0)
            printf("  Processed: %s\n", buf);
#ifdef FIXED
        free(buf);
#endif
    }
}

int main(void) {
    printf("=== Leaky App - LAB-03 Memory Analysis ===\n");

    memstat("truoc");
    printf("[1] Creating %d records...\n", NUM_RECORDS);
    Record **records = malloc(sizeof(Record*) * NUM_RECORDS);
    for (int i = 0; i < NUM_RECORDS; i++)
        records[i] = create_record(i, "EmbeddedLinuxStudent", 5);

    printf("[2] Deleting records (with leak)...\n");
    for (int i = 0; i < NUM_RECORDS; i++)
        delete_record(records[i]);
    free(records);

    printf("[3] Processing messages (with leak)...\n");
#ifdef MEMSTAT
    process_messages(4000);   /* tang tai de thay ro muc tang VmRSS tren target */
#else
    process_messages(50);
#endif

    memstat("sau");
    printf("Program finished - check valgrind output!\n");
    return 0;
}
