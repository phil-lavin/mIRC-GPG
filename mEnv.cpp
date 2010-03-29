#pragma comment(linker,"/DEF:mEnv.def")
#include <windows.h>
#include <stdlib.h>
#include <string.h>

extern "C" int WINAPI _getEnv(HWND mWnd, HWND aWnd, char *data, char *parms,
  BOOL show, BOOL nopause) {

  char * res = getenv(data);
  if (res) {
    strcpy(data, "OK ");
    strcpy((data + 3), res);
  } else {
    strcpy(data, "ERROR Environment variable does not exist.");
  }

  return 3;
}

extern "C" int WINAPI _putEnv(HWND mWnd, HWND aWnd, char *data, char *parms,
  BOOL show, BOOL nopause) {

  if (!strchr(data, '=')) {
    strcpy(data, "ERROR Expected \"putEnv <VARIABLE>=<VALUE>\"");
    return 3;
  }

  if (putenv(data) == -1) {
    strcpy(data, "ERROR Could not set environment variable.");
    return 3;
  }

  strcpy(data, "OK No error.");
  return 3;
}

extern "C" int WINAPI _delEnv(HWND mWnd, HWND aWnd, char *data, char *parms,
  BOOL show, BOOL nopause) {

  if (strchr(data, '=')) {
    strcpy(data, "ERROR Expected \"delEnv <VARIABLE>\"");
    return 3;
  }
  
  strcat(data, "=");

  if (putenv(data) == -1) {
    strcpy(data, "ERROR Could not clear environment variable.");
    return 3;
  }

  strcpy(data, "OK No error.");
  return 3;
}
