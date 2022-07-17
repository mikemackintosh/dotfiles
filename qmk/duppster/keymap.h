#include QMK_KEYBOARD_H

#include <print.h>
#include <string.h>


enum alt_keycodes {
  U_T_AUTO = SAFE_RANGE, //USB Extra Port Toggle Auto Detect / Always Active
  U_T_AGCR,              //USB Toggle Automatic GCR control
  DBG_TOG,               //DEBUG Toggle On / Off
  DBG_MTRX,              //DEBUG Toggle Matrix Prints
  DBG_KBD,               //DEBUG Toggle Keyboard Prints
  DBG_MOU,               //DEBUG Toggle Mouse Prints
  MD_BOOT,               //Restart into bootloader after hold timeout
  CHNG_MD,               //
  TERMINAL,              //
};

enum custom_keycodes {          // Make sure have the awesome keycode ready
  ALT_TAB = TERMINAL + 1,
  ALT_TILDE,
};

enum string_macro_keycodes {
  // The start of this enum should always be equal to end of alt_keycodes + 1
  G_INIT = ALT_TILDE + 1, // git init
  G_CLONE,               // git clone
  G_STATUS,              // git status
  Z_LS,                  // ls -la
  Z_PIN, //pin
  Z_EDB, // edb
};
