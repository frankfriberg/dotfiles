import {
  ifApp,
  map,
  rule,
  withMapper,
  withModifier,
  writeToProfile,
} from "karabiner.ts";

const aerospace = (command: string) => `/opt/homebrew/bin/aerospace ${command}`;

const appMap = {
  s: { name: "Slack", identifier: "com.tinyspeck.slackmacgap" },
  t: { name: "Telegram", identifier: "ru.keepcoder.Telegram" },
  d: { name: "Docker Desktop", identifier: "com.electron.dockerdesktop" },
  f: { name: "Finder", identifier: "com.apple.finder" },
  m: { name: "Mail", identifier: "com.apple.mail" },
};
writeToProfile("default", [
  rule("Left FN to CTRL").manipulators([map("fn").to("left_control")]),
  rule("Map CMD Caps Lock to Hyper").manipulators([
    map("caps_lock", "left_command").toHyper(),
  ]),
  rule("Right Command to Hyper").manipulators([
    map("right_command").toHyper(),
    withModifier("Hyper")([
      withMapper(appMap)((k, { name, identifier }) =>
        map(k).toApp(name).condition(ifApp(identifier).unless()),
      ),
      withMapper(appMap)((k, { identifier }) =>
        map(k).to("w", "left_command").condition(ifApp(identifier)),
      ),
    ]),
  ]),
  rule("Caps Lock Meh").manipulators([
    map("caps_lock").toMeh(),
    withModifier("Meh")([
      withMapper([1, 2, 3, 4])((k) => map(k).to$(aerospace(`workspace ${k}`))),
      map("f").to$(aerospace("layout h_accordion h_tiles")),
      withMapper({
        e: aerospace(
          "focus left --boundaries-action wrap-around-the-workspace --ignore-floating",
        ),
        d: aerospace(
          "focus right --boundaries-action wrap-around-the-workspace --ignore-floating",
        ),
      })((k, v) => map(k).to$(v)),
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
  rule("Aerospace").manipulators([
    withMapper([1, 2, 3, 4])((k) =>
      map(k, "left_option").to$(aerospace(`move-node-to-workspace ${k}`)),
    ),
  ]),
]);
