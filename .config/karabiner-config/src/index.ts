import { map, rule, withModifier, writeToProfile } from "karabiner.ts";

writeToProfile("default", [
  rule("Left FN to CTRL").manipulators([map("fn").to("left_control")]),
  rule("Map CMD Caps Lock to Hyper").manipulators([
    map("caps_lock", "left_command").toHyper(),
  ]),
  rule("Right Command to Hyper").manipulators([map("right_command").toHyper()]),
  rule("Caps Lock Meh").manipulators([
    map("caps_lock").toMeh(),
    withModifier("Meh")([
      map("h").to("8", "left_option"),
      map("l").to("9", "left_option"),
      map("j").to("8", "left_shift"),
      map("k").to("9", "left_shift"),
      map("j", "left_shift").to("8", "left_shift"),
      map("k", "left_shift").to("9", "left_shift"),
      map("u").to("8", ["left_shift", "left_option"]),
      map("i").to("9", ["left_shift", "left_option"]),
      map("o").to("grave_accent_and_tilde"),
      map("p").to("grave_accent_and_tilde", "left_shift"),
    ]),
  ]),
]);
