{ pkgs, ... }:

let
  librepods = pkgs.stdenv.mkDerivation {
    pname = "librepods";
    version = "unstable";

    src = pkgs.fetchFromGitHub {
      owner = "kavishdevar";
      repo = "librepods";
      rev = "5cd7db574a4602e1bb0c485431e70a8e39f9f579";
      sha256 = "sha256-23G71hLCeUODDgubxGpFsHhLZHSXJ2kjzcxmXyEHJ+o=";
    };

    sourceRoot = "source/linux";

    buildInputs = with pkgs; [
      dbus
      egl-wayland
      libpulseaudio

      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtquick3d
      qt6.qtsvg
      qt6.qttools
      qt6.qtconnectivity # bluetooth

      kdePackages.qtstyleplugin-kvantum
      kdePackages.qt6ct
    ];

    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
      qt6.wrapQtAppsHook
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp librepods $out/bin/
    '';
  };
in
{
  home.packages = [ librepods ];

  systemd.user.services.librepods = {
    Unit = {
      Description = "Librepods Airpods Controller";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${librepods}/bin/librepods";
      Restart = "always";
      RestartSec = 3;

      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "QT_QUICK_BACKEND=software"
        "QT_OPENGL=software"
        "QSG_RHI_BACKEND=software"
      ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
