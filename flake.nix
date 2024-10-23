{
  description = "Flutter 3.16.x";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    android.url = "github:tadfisher/android-nixpkgs";
    flutter-nix.url = "github:Degorn/flutter.nix";
  };
  outputs = { self, nixpkgs, flake-utils, android, flutter-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        flutter-sdk = flutter-nix.packages.${system};
        android-sdk = android.sdk.${system} (sdkPkgs:
          with sdkPkgs; [
            build-tools-30-0-3
            build-tools-34-0-0
            cmdline-tools-latest
            emulator
            platform-tools
            platforms-android-30
            platforms-android-31
            platforms-android-33
            platforms-android-34
            sources-android-34
            system-images-android-30-google-apis-playstore-x86-64
            system-images-android-34-google-apis-playstore-x86-64
          ]
        );
      in
      {
        devShell = with pkgs; mkShell rec {
          buildInputs = [
            flutter-sdk.flutter
            jdk
            android-sdk
            lcov
          ];

          JAVA_HOME = jdk.home;
          CHROME_EXECUTABLE = "google-chrome-stable";

          # Fix an issue with Flutter using an older version of aapt2, which does not know
          # an used parameter.
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${android-sdk}/share/android-sdk/build-tools/34.0.0/aapt2";
          FLUTTER_GRADLE_PLUGIN_BUILDDIR = "~/.cache/flutter/gradle-plugin";
        };
      });
}
