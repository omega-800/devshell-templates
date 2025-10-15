{
  description = "flutter development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      systems = nixpkgs.lib.platforms.unix;
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
      buildToolsVer = "34.0.0";
      cmakeVer = "3.10.2";
    in
    {
      devShells = eachSystem (
        pkgs:
        let
          androidPkgs = import nixpkgs {
            inherit (pkgs) system;
            config = {
              android_sdk.accept_license = true;
              allowUnfree = true;
            };
          };
          androidComposition = androidPkgs.androidenv.composeAndroidPackages {
            toolsVersion = "26.1.1";
            platformToolsVersion = "34.0.5";
            buildToolsVersions = [ buildToolsVer ];
            platformVersions = [
              (androidPkgs.lib.versions.major buildToolsVer)
            ];
            includeEmulator = true;
            emulatorVersion = "34.1.9";
            includeSources = false;
            includeSystemImages = true;
            systemImageTypes = [ "google_apis_playstore" ];
            abiVersions = [
              #"armeabi-v7a"
              #"arm64-v8a"
              "x86_64"
            ];
            cmakeVersions = [ cmakeVer ];
            includeNDK = true;
            ndkVersions = [
              "22.0.7026061"
              "23.1.7779620"
            ];
            useGoogleAPIs = true;
            useGoogleTVAddOns = false;
            extraLicenses = [
              "android-googletv-license"
              "android-sdk-arm-dbt-license"
              "android-sdk-license"
              "android-sdk-preview-license"
              "google-gdk-license"
              "intel-android-extra-license"
              "intel-android-sysimage-license"
              "mips-android-sysimage-license"
            ];
          };
          androidSdk = androidComposition.androidsdk;
          jdkPin = androidPkgs.jdk;
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
        in
        {
          default = androidPkgs.mkShellNoCC {
            inherit ANDROID_HOME;
            ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
            ANDROID_AVD_HOME = "/home/omega/.config/.android/avd";
            JAVA_HOME = jdkPin.home;
            LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath [ androidPkgs.sqlite ]}";
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVer}/aapt2";
            shellHook = ''
              export PATH="$(echo "$ANDROID_HOME/cmake/${cmakeVer}".*/bin):$PATH"
            '';
            buildInputs =
              (with androidPkgs; [
                flutter
                sqlite
                xdg-user-dirs
              ])
              ++ [
                androidSdk
                jdkPin
              ];
          };
        }
      );
    };
}
