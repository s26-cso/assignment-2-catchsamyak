#include <stdio.h>
#include <dlfcn.h>

typedef int (*fptr)(int, int);   // you are equating types int and (*fptr)(int, int).
                                 // this means that fptr must be the type of a pointer to a
                                 // function with signature int, int -> int.

int main() {
    char op[6];
    int x, y;
    while(scanf("%5s %d %d", op, &x, &y) == 3){
        char libname[20];
        sprintf(libname, "./lib%s.so", op);
        void* handle = dlopen(libname, RTLD_LAZY);          // bring the library into memory
        if(handle == NULL){
            printf("could not load library %s\n", libname);
            continue;
        }
        fptr opfunc = dlsym(handle, op);                    // get a pointer to the op function
        if(opfunc == NULL){
            printf("could not find function %s in library %s\n", op, libname);
            dlclose(handle);
            continue;
        }
        printf("%d\n", opfunc(x, y));
        dlclose(handle);
    }
    return 0;
}