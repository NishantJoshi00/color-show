#include "window.h"
#include <sys/ioctl.h>

int font_height() {
  struct winsize sz;
  ioctl(0, TIOCGWINSZ, &sz);

  return sz.ws_ypixel / sz.ws_row;
}
