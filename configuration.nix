# Edit this configuration file to define what should be installed on
#
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
iconTheme = pkgs.breeze-icons.out;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Allow unfree...
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ (import /etc/nixos/overlays) ];
  nix = {
    useSandbox = true;
    nixPath = 
      [ "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
        "nixos-config=/etc/nixos/configuration.nix"
        "/nix/var/nix/profiles/per-user/root/channels"
        "nixpkgs-overlays=/etc/nixos/overlays"
      ];
  };

  boot.cleanTmpDir = true;
  boot.supportedFilesystems = ["zfs"];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sdc"; # or "nodev" for efi only

  networking.hostId = "8425e349";
  networking.hostName = "turtaw"; # Define your hostname.
  networking.networkmanager = {
    enable = true;
  };
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };
  time.timeZone = null;

  # QT4/5 global theme
  # environment.etc."xdg/Trolltech.conf" = {
  #   text = ''
  #     [Qt]
  #     style=Breeze
  #   '';
  #   mode = "444";
  # };

# GTK3 global theme (widget and icon theme)
  # environment.etc."xdg/gtk-3.0/settings.ini" = {
  #   text = ''
  #     [Settings]
  #     gtk-icon-theme-name=breeze
  #     gtk-theme-name=Breeze-gtk
  #   '';
  #   mode = "444";
  # };
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # system
    # emacs
    tmux
    git
    gnumake
    htop
    mu
    nix-repl
    vim
    wget
    isync
    file
    pv
    dnsutils
    ag
    lsof
    networkmanager
    wrk
    chromium
    jq
    html2text
    networkmanager

    # Rust dev
    # latest.rustChannels.nightly.rust
    rustracer

    google-cloud-sdk

    nixops

    # raspberry pi stuff
    hdparm
    unzip

    # ui stuff
    notify-osd
    libnotify
    trayer
    rofi
    pa_applet
    haskellPackages.xmobar
    xcape
    xlockmore
    xautolock
    vlc

    # communication
    slack
    quaternion
    weechat
    weechat-matrix-bridge
    # riot-web

    # gui
    xfce.thunar
    firefox # using nightly from the firefox overlay
    # latest.firefox-bin
    enpass
    # google-chrome
    chromium
    # spotify
    terminator
    evince
    transmission
    # (steam.override { nativeOnly = true; runtimeOnly = false; })
    steam
    steam-run-native
    
    # Qt theme
    breeze-qt5
    breeze-qt4
    # theme
    iconTheme

    # fallback themes
    gnome3.adwaita-icon-theme
    hicolor_icon_theme

    # nix Beta
    nixUnstable
  ];
  environment.pathsToLink = ["/share"];

  systemd.services.illum = {
    enable = true;
    description = "Backlight Brightness";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session-pre.target" ];
    serviceConfig.ExecStart = "${pkgs.overlay.illum}/bin/illum-d -l 2.9";
  };
  systemd.user.services.mbsync = {
    enable = true;
    description = "Run mbsync";
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${pkgs.isync}/bin/mbsync -a";
  };
  systemd.user.timers.mbsync = {
    enable = true;
    description = "run mbsync every 5 minutes";
    timerConfig = {
      OnBootSec = "10m";
      OnUnitInactiveSec = "5m";
      Unit = "mbsync.service";
    };
  };

  systemd.user.services.mu-fastmail = {
    enable = true;
    description = "Update email index for fastmail";
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${pkgs.mu}/bin/mu index -m /home/moredhel/mail";
  };
  systemd.user.timers.mu-fastmail = {
    enable = true;
    description = "run mu-fastmail every 5 minutes";
    timerConfig = {
      OnBootSec = "11m";
      OnUnitInactiveSec = "2m";
      Unit = "mu-fastmail.service";
    };
  };


  networking.firewall.enable = true;
  networking.firewall.checkReversePath = false;
  networking.firewall.allowedTCPPorts = [8000];
  networking.firewall.allowedUDPPorts = [];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services = {
    transmission = {
      enable = true;
      settings = {
        download-dir = "/data/media/torrent/";
        incomplete-dir = "/data/media/torrent/.incomplete";
      };
    };
    emacs = {
      enable = true;
      install = true;
      defaultEditor = true;
      
    };
    # openvpn.servers = {
    #   vps = {
    #     config = '' config /home/moredhel/turtaw.ovpn '';
    #     updateResolvConf = true;
    #   };
    # };
    bitlbee = {
      enable = true;
      plugins = [ pkgs.bitlbee-facebook ];
    };
    openssh.enable = false;
    urxvtd = {
      enable = true;
    };
    xserver = {
      layout = "dvorak";
      enable = true;
      autorun = true;
      exportConfiguration = true;
      libinput = {
          enable = false;
          tapping = false;
          accelSpeed = "1";
      };    
      displayManager.lightdm.enable = true;

      videoDrivers = [ "intel" ];
      updateDbusEnvironment = true;

      desktopManager.gnome3.enable = true;
      # windowManager.default = "xmonad";
      # windowManager.xmonad.enable = true;
      # windowManager.xmonad.enableContribAndExtras = true;

      desktopManager.xterm.enable = false;
      desktopManager.default = "custom";
      desktopManager.session =
      [ {
          name = "custom";
          start = ''
            # exec .xsession
          '';
        }
      ];

      # Make caps lock an additional ctrl key
      xkbOptions = "ctrl:nocaps";
    };
    cjdns = {
      enable = true;
      UDPInterface = {
        bind = "0.0.0.0:43211";
        connectTo = {
		      "54.36.18.68:43211" = {
		        # "contact" = "hamish@aoeu.me",
		        password = "aujas.mcgsqntuhntwsnteoauhsnteodaeobkjqvkbHSNTUOHAONUonthueontuh";
            hostname = "nixos-master";
		        publicKey = "0194d7156x7jjq8793u8tyl1q9lm18ufbvwv263uf0wbwj0pssd0.k";
		      };
        };
      };
      # confFile = /etc/nixos/private/cjdroute.conf;
    };
    ipfs = {
      enable = true;
      autoMount = false;
    };
    syncthing = {
      enable = true;
      useInotify = true;
      user = "moredhel";
      dataDir = "/etc/nixos/private/syncthing";
      openDefaultPorts = true;
    };
    postfix = {
      enable = true;
      hostname = "turtaw.local";
      config = {
        relayhost = "[smtp.fastmail.com]:587";
        smtp_sasl_auth_enable = true;
        smtp_sasl_security_options = "noanonymous";
        smtp_use_tls = true;
        smtp_sasl_password_maps = "hash:/etc/nixos/private/sasl_passwd";
      };
    };
    redshift = {
      enable = true;
      latitude = "55.9";
      longitude = "3.1";
    };
    zfs = {
      autoSnapshot.enable = true;
      autoScrub.enable = true;
    };
  };
  programs.bash = {
    shellInit = ''
      export TESTING=TRUE
    '';
    enableCompletion = true;
  };
  programs.ssh = {
    startAgent = true;
  };
  programs.tmux = {
    enable = true;
    clock24 = true;
    extraTmuxConf = ''
    set -g mouse on;
    '';
  };

  powerManagement.scsiLinkPolicy = null;
  powerManagement.powertop.enable = true;
  powerManagement.enable = true;
  powerManagement.powerDownCommands = ''
    systemctl stop openvpn-vps
    pkill notify-osd
  '';
  powerManagement.powerUpCommands = ''
    systemctl start openvpn-vps
    notify-osd &
  '';

  users.mutableUsers = false;
  users.extraUsers.moredhel = {
    isNormalUser = true;
    extraGroups = ["wheel" "systemd-journal" "users" "docker" "postdrop" "ipfs" "libvirtd" "networkmanager"];
    password = (pkgs.lib.fileContents /etc/nixos/private/user_passwd);
    uid = 1000;
  };

  virtualisation = {
    docker.enable = true;
    docker.enableOnBoot = false;
    docker.package = pkgs.docker-edge;
    libvirtd.enable = true;
  };
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

  sound.mediaKeys.enable = true;

  hardware = {
    opengl.driSupport32Bit = true;
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
    trackpoint = {
      enable = true;
      sensitivity = 255;
      speed = 255;
      emulateWheel = true;
      fakeButtons = true;
    };
  };

}
