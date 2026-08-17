{
  lib,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  bzip2,
  zstd,
  stdenv,
  callPackage,
  nix-update-script,
  testers,
  matrix-continuwuity,
  rust-jemalloc-sys-unprefixed,
  liburing,
  nixosTests,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "matrix-continuwuity";
  version = "26.8.0-alpha.1-unstable-2026-08-16";

  src = fetchFromGitea {
    domain = "forgejo.ellis.link";
    owner = "continuwuation";
    repo = "continuwuity";
    rev = "e1d7974dbb437d7f5c218f9fa621df10c0aa97b3";
    hash = "sha256-55NIXtNTVJu2oYYo1Wl+9g+FzXf4zxjk0NTEe+ZTUAA=";
  };

  cargoHash = "sha256-5aR319rqAbZeM8Uex68C2TYsxgXcLbBLE8mm8yy2Qks=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    bzip2
    zstd
    rust-jemalloc-sys-unprefixed
    liburing
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
    ROCKSDB_INCLUDE_DIR = "${finalAttrs.rocksdb}/include";
    ROCKSDB_LIB_DIR = "${finalAttrs.rocksdb}/lib";
  };

  rocksdb = callPackage ./rocksdb.nix { }; # make used rocksdb version available (e.g., for backup scripts)

  passthru = {
    updateScript = nix-update-script { };
    tests = {
      version = testers.testVersion {
        inherit (finalAttrs) version;
        package = matrix-continuwuity;
      };
    }
    // lib.optionalAttrs stdenv.hostPlatform.isLinux {
      inherit (nixosTests) matrix-continuwuity;
    };
  };

  meta = {
    description = "Matrix homeserver written in Rust, forked from conduwuit";
    homepage = "https://continuwuity.org/";
    changelog = "https://forgejo.ellis.link/continuwuation/continuwuity/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      bartoostveen
      nyabinary
      snaki
    ];
    # Not a typo, continuwuity is a drop-in replacement for conduwuit.
    mainProgram = "conduwuit";
  };
})
