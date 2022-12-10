#pragma once

#include "keymap.h"

#if __has_include("secrets.h")
# include "secrets.h"
#endif

#ifndef SECRET_PIN
  #define SECRET_PIN "ok"
#endif
#ifndef SECRET_PHARSE
  #define SECRET_PHARSE "ok"
#endif
#ifndef SECRET_PHARSE2
  #define SECRET_PHARSE "ok"
#endif

keymap_config_t keymap_config;

bool is_space_cadet_shift_active = false; //

#ifndef OPENPAREN_KEY
  #define OPENPAREN_KEY KC_9
#endif
#ifndef CLOSEPAREN_KEY
  #define CLOSEPAREN_KEY KC_0
#endif

static const char * cmds[] = {
    "git init ",
    "git clone ",
    "git status ",
    "ls -la ",
    SECRET_PIN,
    SECRET_PHARSE,
    SECRET_PHARSE2,
};


const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [0] = LAYOUT_65_ansi_blocker(
    S_ESC,   KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_MINS, KC_EQL,  KC_BSPC, KC_DEL,  \
    KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_LBRC, KC_RBRC, KC_BSLS, KC_HOME, \
    KC_CAPS, KC_A,    KC_S,    KC_D,    KC_F,    KC_G,    KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_QUOT,          KC_ENT,  KC_PGUP, \
    KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_RSFT,          KC_UP,   KC_PGDN, \
    KC_LCTL, KC_LALT, KC_LGUI,                            KC_SPC,                             KC_RALT, MO(1),   KC_LEFT, KC_DOWN, KC_RGHT  \
  ),
  [1] = LAYOUT_65_ansi_blocker(
    KC_GRV,  KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,  KC_F12,  _______, KC_MUTE, \
    _______, RGB_SPD, RGB_VAI, RGB_SPI, RGB_HUI, RGB_SAI, _______, U_T_AUTO,U_T_AGCR,_______, KC_PSCR, KC_SCRL, KC_PAUS, _______, KC_END, \
    KC_LSCR, RGB_RMOD,RGB_VAD, RGB_MOD, RGB_HUD, RGB_SAD, _______, _______, _______, Z_LS,    _______,   E_SP2,          _______, KC_BRIU, \
    _______, RGB_TOG, _______, _______, _______, MD_BOOT, NK_TOGG, DBG_TOG, _______, LAG_SWP,   E_PIN,   E_EDB,          KC_VOLU, KC_BRID, \
    _______, _______, _______,                            KC_MPLY,                            _______, _______, KC_MRWD, KC_VOLD, KC_MFFD  \
  ),
  /*
  [X] = LAYOUT(
    _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
    _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
    _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,          _______, _______, \
    _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,          _______, _______, \
    _______, _______, _______,                            _______,                            _______, _______, _______, _______, _______  \
  // ),
  */
};

// Runs just one time when the keyboard initializes.
void matrix_init_user(void) {
  debug_enable = true;
  debug_keyboard = true;
};

// Runs constantly in the background, in a loop.
void matrix_scan_user(void) { // The very important timer.
}

#define MODS_SHIFT  (get_mods() & MOD_BIT(KC_LSFT) || get_mods() & MOD_BIT(KC_RSFT))
#define MODS_CTRL  (get_mods() & MOD_BIT(KC_LCTL) || get_mods() & MOD_BIT(KC_RCTL))
#define MODS_ALT  (get_mods() & MOD_BIT(KC_LALT) || get_mods() & MOD_BIT(KC_RALT))
#define MODS_RALT  (get_mods() & MOD_BIT(KC_RALT))

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    static uint32_t key_timer;

    switch (keycode) {
      case S_ESC:
        if (record->event.pressed) {
          unregister_code(KC_ESC);

          // Ctrl + Esc =
          if (MODS_SHIFT || MODS_ALT || MODS_CTRL) {
            register_code(KC_GRV);
            unregister_code(KC_GRV);
            return false;
          }

          register_code(KC_ESC);
          unregister_code(KC_ESC);
          return false;
        }
        return false;

      case KC_CAPS:
          if (record->event.pressed) {
            if(MODS_SHIFT) {
              uint16_t _shift;

              if (get_mods() & MOD_BIT(KC_LSFT)) {
                _shift = KC_LSFT;
              } else {
                _shift = KC_RSFT;
              }

              unregister_code(_shift);
              register_code(KC_GRV);
              unregister_code(KC_GRV);
              register_code(_shift);
              return false;
            }

            register_code(KC_CAPS);
          }
          return false;

      case S_CDS:
          if (record->event.pressed) {

          }
          return false;

      case CHNG_MD:
          if (record->event.pressed) {
              dprintf("change_mode pressed\r\n");
          }
          return false;

      case U_T_AUTO:
          if (record->event.pressed && MODS_SHIFT && MODS_CTRL) {
          TOGGLE_FLAG_AND_PRINT(usb_extra_manual, "USB extra port manual mode");
          }
          return false;
      case U_T_AGCR:
          if (record->event.pressed && MODS_SHIFT && MODS_CTRL) {
              TOGGLE_FLAG_AND_PRINT(usb_gcr_auto, "USB GCR auto mode");
          }
          return false;
      case DBG_TOG:
          if (record->event.pressed) {
              TOGGLE_FLAG_AND_PRINT(debug_enable, "Debug mode");
          }
          return false;
      case DBG_MTRX:
          if (record->event.pressed) {
              TOGGLE_FLAG_AND_PRINT(debug_matrix, "Debug matrix");
          }
          return false;
      case DBG_KBD:
          if (record->event.pressed) {
              TOGGLE_FLAG_AND_PRINT(debug_keyboard, "Debug keyboard");
          }
          return false;
      case DBG_MOU:
          if (record->event.pressed) {
              TOGGLE_FLAG_AND_PRINT(debug_mouse, "Debug mouse");
          }
          return false;
      case MD_BOOT:
          if (record->event.pressed) {
              key_timer = timer_read32();
          } else {
              if (timer_elapsed32(key_timer) >= 500) {
                  reset_keyboard();
              }
          }
          return false;

      case RGB_TOG:
          if (record->event.pressed) {
            switch (rgb_matrix_get_flags()) {
              case LED_FLAG_ALL: {
                  rgb_matrix_set_flags(LED_FLAG_KEYLIGHT);
                  rgb_matrix_set_color_all(0, 0, 0);
                }
                break;
              case LED_FLAG_KEYLIGHT: {
                  rgb_matrix_set_flags(LED_FLAG_UNDERGLOW);
                  rgb_matrix_set_color_all(0, 0, 0);
                }
                break;
              case LED_FLAG_UNDERGLOW: {
                  rgb_matrix_set_flags(LED_FLAG_NONE);
                  rgb_matrix_disable_noeeprom();
                }
                break;
              default: {
                  rgb_matrix_set_flags(LED_FLAG_ALL);
                  rgb_matrix_enable_noeeprom();
                }
                break;
            }
          }
          return false;

      case G_INIT ... Z_LS:
          if (record->event.pressed) {
              send_string_with_delay(cmds[keycode - G_INIT], 1);
          }

          break;

      case E_PIN ... E_SP2:
          if (record->event.pressed) {
              send_string_with_delay(cmds[keycode - G_INIT], 1);
              register_code(KC_ENT);
              unregister_code(KC_ENT);
          }

          break;
    }

    return true; //Process all other keycodes normally
}
