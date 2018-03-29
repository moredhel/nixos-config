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
      <nixos-hardware/lenovo/thinkpad/x230> ./hardware-configuration.nix
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
  boot.zfs.enableUnstable = true;
  boot.supportedFilesystems = ["zfs"];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sdc"; # or "nodev" for efi only
  # boot.kernelPackages = pkgs.linuxPackages_latest; # Meltdown/Spectre patch, currently broken

  networking.hostId = "8425e349";
  networking.hostName = "turtaw"; # Define your hostname.
  # networking.interfaces.enp0s25.ip4 = [{ address = "192.168.1.1"; prefixLength = 24; }];
  networking.networkmanager = {
    enable = true;
  };
  networking.extraHosts = ''
    127.0.0.1 lycaon1.address
    127.0.0.1 lycaon2.address
  '';
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.254/24" ];
      privateKey = "+C76qS66IHScpFPCoS4pxgyawIkq52stQn6xHU4cOWg=";
      # publicKey = "mF+e1jD+sKGBAgxishCNxHz3FGDl/4tivlNMGWBd3Go=";

      peers = [{
        publicKey = "Rj9G2Cfw1+NrzKj9co66pWRcttSXdE0Xkw+QslDNkkw=";
        allowedIPs = [ "10.100.0.0/24" ];
        endpoint = "54.36.18.68:5555";
        persistentKeepalive = 25;
      }];
    };
  };

  fonts = {
    fonts = [
      pkgs.fira-mono
    ];
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
    mu # user
    nix-repl
    vim
    wget
    isync # user
    file
    pv
    dnsutils
    ag
    lsof
    networkmanager
    wrk # ?? follow this up
    chromium # user
    jq
    html2text # user

    exfat-utils
    # Rust dev
    # latest.rustChannels.nightly.rust
    rustracer # user

    google-cloud-sdk # user

    # raspberry pi stuff
    hdparm # user
    unzip

    # ui stuff
    notify-osd # user
    libnotify # user
    trayer # user
    rofi # user
    pa_applet # user
    haskellPackages.xmobar # user
    xcape # user
    xlockmore # user
    xautolock # user
    vlc # user

    overlay.thunar # user
    # xfce.thunar

    # communication
    # slack # user
    quaternion # user
    weechat # user
    weechat-matrix-bridge # user
    # riot-web

    # gui
    # firefox # using nightly from the firefox overlay
    # latest.firefox-bin
    # enpass # user
    # google-chrome
    chromium # user
    # spotify
    terminator # user
    evince # user
    transmission # user
    # (steam.override { nativeOnly = true; runtimeOnly = false; })
    # steam # user
    # steam-run-native # user
    
    # Qt theme
    breeze-qt5
    breeze-gtk
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
    # TODO: fix this...
    enable = true;
    description = "Backlight Brightness";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
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
  networking.firewall.allowedTCPPorts = [8000 8001 3306];
  networking.firewall.allowedUDPPorts = [];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services = {
    keybase.enable = true;
    kbfs = {
      enable = true;
    };
    tlp.enable = true;

    minidlna = {
      enable = false;
      mediaDirs = [
        "/data/media"
      ];
    };

    tt-rss = {
      enable = false;
      selfUrlPath = "http://me.aoeu.me";
      virtualHost = "me.aoeu.me";
      database = {
        host = "nixos-docker.hamhut1066.com";
        port = 5432;
        password = "somepassword";
      };
      singleUserMode = true;
      enableGZipOutput = false;
    };
    postgresql.enable = false;
    dhcpd4 = {
      enable = false;
      interfaces = ["enp0s25"];
      extraConfig = ''
        subnet 192.168.1.0 netmask 255.255.255.0 {
       option routers                  192.168.1.1; #Default Gateway
       option subnet-mask              255.255.255.0;
       option domain-name              "home.local";
       option domain-name-servers      192.168.1.2;
       option netbios-name-servers     192.168.1.2; #WINS Server        
    range dynamic-bootp 192.168.1.51 192.168.1.100;  #DHCP Range to assign
       default-lease-time 43200;
       max-lease-time 86400;
      }
      '';
    };
    unifi = {
      enable = false;
    };
    traefik = {
      enable = false;
      # group = "docker";
      configOptions = {
        defaultEntryPoints = [ "http" ];
        web = {
          address = ":8080";
        };
        docker  ={
          endpoint = "unix:///var/run/docker.sock";
          domain = "home.local";
          watch = true;
          exposedbydefault = false;
        };
      };
    };
    nginx = {
      enable = false;
      statusPage = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      virtualHosts = {
        # "lycaon1.address" = {
        #   locations."/" = {
        #     proxyPass = "http://localhost:8002/";
        #   };
        # };
        "lycaon2.address" = {
          locations."/" = {
            proxyPass = "http://localhost:8003/";
          };
        };
        "lychee" = {
          locations."/" = {
          };
        };
      };
    };
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
    bitlbee = {
      enable = false;
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
        enable = true;
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
      enable = false;
      autoMount = false;
    };
    syncthing = {
      enable = true;
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
  powerManagement.powertop.enable = false;
  powerManagement.enable = false;
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
    extraGroups = ["wheel" "systemd-journal" "users" "docker" "postdrop" "ipfs" "libvirtd" "networkmanager" "rkt"];
    password = (pkgs.lib.fileContents /etc/nixos/private/user_passwd);
    uid = 1000;
  };

  virtualisation = {
    rkt.enable = true;
    docker.enable = true;
    docker.enableOnBoot = false;
    docker.package = pkgs.docker-edge;
    libvirtd.enable = true;
  };
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

  sound.mediaKeys.enable = true;

  hardware = {
    bluetooth.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
    trackpoint = {
      enable = true;
      sensitivity = 1000;
      speed = 1000;
      emulateWheel = true;
      fakeButtons = true;
    };
  };

}
