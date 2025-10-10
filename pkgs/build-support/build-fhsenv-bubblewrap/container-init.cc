#include <fstream>

#include <fcntl.h>
#include <spawn.h>
#include <string.h>
#include <unistd.h>

#include <sys/wait.h>

const char LD_SO_CONF[] = R"(/lib
/lib/x86_64-linux-gnu
/lib64
/usr/lib
/usr/lib/x86_64-linux-gnu
/usr/lib64
/lib/i386-linux-gnu
/lib32
/usr/lib/i386-linux-gnu
/usr/lib32
/run/opengl-driver/lib
/run/opengl-driver-32/lib
)";

int main(int argc, const char *argv[]) {
  std::ofstream ld_so_conf;
  ld_so_conf.open("/etc/ld.so.conf");
  ld_so_conf << LD_SO_CONF;
  ld_so_conf.close();
  if (!ld_so_conf) {
    perror("Failed to generate ld.so.conf");
    return 1;
  }

  int e;
  pid_t pid;
  const char *ldconfig_argv[] = {"sh", "-c", "/bin/ldconfig 2>&1 >/tmp/dumps/container-init.log", NULL};
  char *ldconfig_envp[] = {NULL};
  if ((e = posix_spawn(&pid, ldconfig_argv[0], NULL, NULL,
                       (char *const *)ldconfig_argv, ldconfig_envp))) {
    fprintf(stderr, "Failed to run ldconfig: %s\n", strerror(e));
    return 1;
  }

  int status;
  if (waitpid(pid, &status, 0) == -1) {
    perror("Failed to wait for ldconfig");
    return 1;
  }
  if (WIFEXITED(status)) {
    if (WEXITSTATUS(status)) {
      fprintf(stderr, "ldconfig exited %d\n", WEXITSTATUS(status));
      fprintf(stderr, "status: %d\n", status);
      // return 1;
    }
  } else {
    fprintf(stderr, "ldconfig killed by signal %d\n", WTERMSIG(status));
    return 1;
  }

  argv[0] = "/init";
  FILE *f = fopen(argv[0], "rb");
  fseek(f, 0, SEEK_END);
  long fsize = ftell(f);
  fseek(f, 0, SEEK_SET);

  char *file_contents = (char *)malloc(fsize + 1);
  fread(file_contents, fsize, 1, f);
  fclose(f);
  file_contents[fsize] = '\0';

  fprintf(stderr, "file:\n%s\n", file_contents);
  execv(argv[0], (char *const *)argv);

  perror("Failed to exec stage 2 init");
  return 1;
}
