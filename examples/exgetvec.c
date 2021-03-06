#include <stdio.h>
#include <wfdb/wfdb.h>

main()
{
    int i, j, nsig;
    WFDB_Sample *v;
    WFDB_Siginfo *s;

    nsig = isigopen("100s", NULL, 0);
    if (nsig < 1)
	exit(1);
    s = (WFDB_Siginfo *)malloc(nsig * sizeof(WFDB_Siginfo));
    if (isigopen("100s", s, nsig) != nsig)
        exit(1);
    v = (WFDB_Sample *)malloc(nsig * sizeof(WFDB_Sample));
    for (i = 0; i < 10; i++) {
        if (getvec(v) < 0)
            break;
        for (j = 0; j < nsig; j++)
            printf("%8d", v[j]);
        printf("\n");
    }
    exit(0);
}
