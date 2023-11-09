with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    zig
    entr
  ];
}
