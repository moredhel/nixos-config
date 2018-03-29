{ pkgs, ... }:

let
  xmonad = pkgs.xmonad-with-packages.override {
  packages = self: [
    self.xmonad-contrib
    self.xmonad-extras
  ];
};
in
{
  home.packages = [
    pkgs.telepresence
    pkgs.awscli
    pkgs.acpi
    pkgs.docker_compose
    pkgs.gnome3.gnome_terminal
    pkgs.google-chrome
    pkgs.inkscape
    pkgs.lispPackages.quicklisp
    pkgs.nix-prefetch-git
    pkgs.autojump

    pkgs.overlay.nixops.nixops

    pkgs.keybase
    pkgs.grobi
    pkgs.overlay.extscreen

    pkgs.pandoc

    pkgs.hledger
    pkgs.pypi2nix
    pkgs.skypeforlinux # issue with hash...
    pkgs.spotify
    pkgs.enpass
    pkgs.telnet
    pkgs.wireshark-gtk
    pkgs.xorg.xmodmap
    pkgs.zip
    pkgs.htop
    pkgs.fortune
    pkgs.enlightenment.terminology

    pkgs.overlay.slack-term
    pkgs.overlay.pushoverWrapper
    pkgs.rlwrap
    pkgs.electrum

    pkgs.gnupg
    pkgs.pass
    pkgs.franz

    pkgs.mozilla.firefox.latest.firefox-nightly-bin
  ];

  home.keyboard = {
    layout = "dvorak";
  };

  services.unclutter = {
    enable = true;
  };

  services.parcellite = {
    enable = true;
  };

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
    inactiveInterval = 5;
  };
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
  };
  services.network-manager-applet = {
    enable = true;
  };

  services.gpg-agent = {
    enable = false;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  xsession = {
    enable = true;
    windowManager.command = "${xmonad}/bin/xmonad";
    initExtra = ''
        ${pkgs.trayer}/bin/trayer --edge top --height 14.5 --width 8 --align right --transparent true --alpha 0 --tint '0x141314' --monitor 1 --SetDockType true &
        ${pkgs.pa_applet}/bin/pa-applet &

        ${pkgs.xcape}/bin/xcape
        ${pkgs.feh}/bin/feh --bg-fill --randomize /home/moredhel/Pictures/wallpapers/*

        # start timers
        systemctl --user start mbsync.timer
        systemctl --user start mu-fastmail.timer

        trap 'trap - SIGINT SIGTERM EXIT && kill 0 && wait' SIGINT SIGTERM EXIT
    '';
  };

  programs.rofi = {
    enable = true;
  };

  programs.emacs = {
    enable = false;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.magit
    ];
  };

  programs.firefox = {
    enable = false;
    enableIcedTea = true;
  };

  programs.browserpass = {
    enable = true;
    browsers = ["firefox" "chromium"];
  };

  programs.git = {
    enable = true;
    userName = "Hamish Hutchings";
    userEmail = "moredhel@aoeu.me";
    aliases = {
      co = "checkout";
      s = "status";
      d = "diff --color";
      a = "add";
      cm = "commit";
      l = "log --color";
      b = "branch";
      f = "flow";
    };
    extraConfig = ''
      [color]
      ui = true

      [merge]
      conflictstyle = diff3
      tool = vimdiff
      
      [push]
      default = simple
    '';
  };
  programs.home-manager = {
    enable = true;
    path = https://github.com/rycee/home-manager/archive/master.tar.gz;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.breeze-qt5;
      name = "Breeze-gtk";
    };
    iconTheme = {
      package = pkgs.breeze-qt5;
      name = "breeze";
    };
  };
}
