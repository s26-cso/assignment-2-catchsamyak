#include <stdio.h>
#include <dlfcn.h>

typedef int (*fptr)(int, int);   // you are equating types int and (*fptr)(int, int).
                                 // this means that fptr must be the type of a pointer to a
                                 // function with signature int, int -> int.

int main() {
    char op[6];
    int x, y;
    while(scanf("%s %d %d", op, &x, &y) == 3){
        char libname[20];
        sprintf(libname, "./lib%s.so", op);
        void* handle = dlopen(libname, RTLD_LAZY);          // bring the library into memory
        fptr opfunc = dlsym(handle, op);                    // get a pointer to the op function
        printf("%d\n", opfunc(x, y));
        dlclose(handle);
    }
    return 0;
}