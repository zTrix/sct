#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/types.h> /* See NOTES */
#include <sys/wait.h>
#include <sys/socket.h>

#define BUF_SIZE 1048576
char buf[BUF_SIZE];
int pid1, pid2;
int sock;
int ready;
int thumb_mode = 0;

void usage(char * err);
int main(int argc, char **argv);

int get_pipe_in();
int load_from_file(char *fname);
int copy_from_argument(char *arg);
void escape_error();

int create_sock();
void run_reader(int);
void run_writer(int);
void set_ready(int sig);

void run_shellcode(void *sc_ptr, int size);
void print_regs();

void usage(char * err) {
    printf("Shellcode Testing program\n\
    Usage:\n\
        sct [-t] [-g] {-f file | $'\\xeb\\xfe' | '\\xb8\\x39\\x05\\x00\\x00\\xc3'}\n\
    Options:\n\
        -g  wait for gdb connection for debug\n\
        -f  read shellcode from file\n\
        -t  switch thumb mode (ARM only)\n\
    Example:\n\
        $ sct $'\\xeb\\xfe'                 # raw shellcode\n\
        $ sct '\\xb8\\x39\\x05\\x00\\x00\\xc3'  # escaped shellcode\n\
        $ sct -f test.sc                  # shellcode from file\n\
        $ sct -f <(python gen_payload.py) # test generated payload\n\
        $ sct -s 5 -f test.sc             # create socket at fd=5 (STDIN <- SOCKET -> STDOUT)\n\
            # Allows to test staged shellcodes\n\
            # Flow is redirected like this: STDIN -> SOCKET -> STDOUT\n\
    Note:\n\
        You should always use single quote in shell to avoid escape by sh\n\
    Compiling:\n\
        gcc -Wall sct.c -o sct\n\
    Author: hellman (hellman1908@gmail.com) zTrix (i@ztrix.me)\n");
    if (err) fprintf(stderr, "\nerr: %s\n", err);
    exit(10);
}

int main(int argc, char **argv) {
    char * fname = NULL;
    int c;

    pid1 = pid2 = -1;
    sock = -1;
    int debug = 0;

    while ((c = getopt(argc, argv, "tghus:f:")) != -1) {
        switch (c) {
            case 'f':
                fname = optarg;
                break;
            case 'g':
                debug = 1;
                break;
            case 's':
                sock = atoi(optarg);
                if (sock <= 2 || sock > 1024)
                    usage("bad descriptor number for sock");
                break;
            case 't':
                thumb_mode = 1;
                break;
            case 'h':
            case 'u':
                usage(NULL);
            default:
                usage("unknown argument");
        }
    }

    int size = 0;

    if (!isatty(0)) {
        int size = get_pipe_in();
        if (size == 0) {
            fprintf(stderr, "read 0 bytes from pipe\n");
            exit(11);
        }
    } else if (optind < argc) {
        size = copy_from_argument(argv[optind]);
        fprintf(stderr, "copied %d bytes from command line args\n", size);
    } else if (fname) {
        size = load_from_file(fname);
    } else if (sock != -1) {
        int created_sock = create_sock(sock);
        fprintf(stderr, "Created socket %d\n", created_sock);
    } else {
        usage("please provide shellcode via either argument or file");
    }

    void * ps = (void *) ((uintptr_t)buf - ((uintptr_t)buf & (uintptr_t)0xfff));
    fprintf(stderr, "buf = %p, mprotect %p \n", buf, ps);
    int ret = mprotect(ps, sizeof(buf) + ((uintptr_t)buf & (uintptr_t)0xfff), 7);
    if (ret < 0) {
        fprintf(stderr, "mprotect failed (return %d)\n", ret);
        return 15;
    }
    
    if (pid1 > 0) kill(pid1, SIGUSR1);
    if (pid2 > 0) kill(pid2, SIGUSR1);

    if (debug) {
        fprintf(stderr, "connect debugger using gdb/lldb -p %d\n", getpid());
        if (!isatty(0)) {
            fprintf(stderr, "wait 5 seconds to run shellcode...\n");
            sleep(5);
        } else {
            fprintf(stderr, "press enter to run shellcode...\n");
            getchar();
        }
    }

    fprintf(stderr, "running shellcode...\n");

    run_shellcode(buf, size);
    return 100;
}

int get_pipe_in() {
    int p = 0;
    while (1) {
        if (p >= BUF_SIZE) {
            fprintf(stderr, "shellcode too large\n");
            exit(10);
        }
        int rd = read(0, &buf[p], BUF_SIZE - p > 4096 ? 4096 : BUF_SIZE - p);
        if (rd <= 0) break;
        p += rd;
    }
    fprintf(stderr, "Read %d bytes from stdin\n", p);
    return p;
}

int load_from_file(char *fname) {
    int fd = open(fname, O_RDONLY);
    if (fd < 0) {
        fprintf(stderr, "fopen %s failed\n", fname);
        exit(100);
    }

    int p = 0;
    while (1) {
        if (p >= BUF_SIZE) {
            fprintf(stderr, "shellcode too large\n");
            exit(10);
        }
        int rd = read(fd, &buf[p], BUF_SIZE - p > 4096 ? 4096 : BUF_SIZE - p);
        if (rd <= 0) break;
        p += rd;
    }

    fprintf(stderr, "Read %d bytes from '%s'\n", p, fname);
    close(fd);
    return p;
}

int copy_from_argument(char *arg) {
    //try to translate from escapes ( \xc3 )

    bzero(buf, sizeof(buf));
    strncpy(buf, arg, sizeof(buf));

    int i;
    char *p1 = buf;
    char *p2 = buf;
    char *end = p1 + strlen(p1);

    int size = 0;
    while (p1 < end) {
        i = sscanf(p1, "\\x%02x", (unsigned int *)p2);
        if (i != 1) {
            if (p2 == p1) {
                if (p1 == buf) {
                    size = strlen(p1);
                } else {
                    size = p2 - buf;
                }
                break;
            }
            else escape_error();
        }

        p1 += 4;
        p2 += 1;
        size = p2 - buf;
    }
    return size;
}

void escape_error() {
    printf("Shellcode is incorrectly escaped!\n");
    exit(1);
}

int create_sock() {
    int fds[2];
    int sock2;
        
    int result = socketpair(AF_UNIX, SOCK_STREAM, 0, fds);
    if (result == -1) {
        perror("socket");
        exit(101);
    }

    if (sock == fds[0]) {
        sock2 = fds[1];
    }
    else if (sock == fds[1]) {
        sock2 = fds[0];
    }
    else {
        dup2(fds[0], sock);
        close(fds[0]);
        sock2 = fds[1];
    }

    ready = 0;
    signal(SIGUSR1, set_ready);

    /*
    writer: stdin -> socket (when SC exits/fails, receives SIGCHLD and exits)
    \--> main: shellcode (when exits/fails, sends SIGCHLD to writer and closes socket)
         \--> reader: sock -> stdout (when SC exits/fails, socket is closed and reader exits)

    main saves pid1 = reader,
               pid2 = writer
    to send them SIGUSR1 right before running shellcode
    */

    pid1 = fork();
    if (pid1 == 0) {
        close(sock);
        run_reader(sock2);
    }

    pid2 = fork();
    if (pid2 > 0) { // parent - writer
        signal(SIGCHLD, exit);
        close(sock);
        run_writer(sock2);
    }
    pid2 = getppid();

    close(sock2);
    return sock;
}

void run_reader(int fd) {
    char buf[4096];
    int n;

    while (!ready) {
        usleep(1);
    }

    while (1) {
        n = read(fd, buf, sizeof(buf));
        if (n > 0) {
            printf("RECV %d bytes FROM SOCKET: ", n);
            fflush(stdout);
            write(1, buf, n);
        }
        else {
            exit(0);
        }
    }
}

void run_writer(int fd) {
    char buf[4096];
    int n;
    
    while (!ready) {
        usleep(1);
    }

    while (1) {
        n = read(0, buf, sizeof(buf));
        if (n > 0) {
            printf("SENT %d bytes TO SOCKET\n", n);
            write(fd, buf, n);
        }
        else {
            shutdown(fd, SHUT_WR);
            close(fd);
            wait(&n);
            exit(0);
        }
    }
}

void set_ready(int sig) {
    ready = 1;
}

void run_shellcode(void *sc_ptr, int size) {

    // keep it clean here, to make it easy to set breakpoint (b run_shellcode)
    void (*ptr)();

    int ret = 0;
    
    ptr = (void *)((uintptr_t)sc_ptr | thumb_mode);

    print_regs();

    (*ptr)();

    print_regs();

    if (sock != -1) {
        close(sock);
    }
    
    int status = 0;
    wait(&status);

    fprintf(stderr, "Shellcode returned %d\n", ret);
    exit(0);
}

