# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./networking.nix
    ./audio.nix
  ];
  home-manager.users.mk = import ../../home/mk.nix;

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  #boot.loader.efi.canTouchEfiVariables = true;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # assuming /boot is the mount point of the  EFI partition in NixOS (as the installation section recommends).
      efiSysMountPoint = "/boot";
    };
    grub = {
      # despite what the configuration.nix manpage seems to indicate,
      # as of release 17.09, setting device to "nodev" will still call
      # `grub-install` if efiSupport is true
      # (the devices list is not used by the EFI grub install,
      # but must be set to some value in order to pass an assert in grub.nix)
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      useOSProber = true;
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # load amdgpu module early. load v4l2loopback for virtual video devices
  boot.initrd.kernelModules = [ "amdgpu" "v4l2loopback" ];
  boot.extraModulePackages = [ pkgs.linuxPackages_latest.v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback video_nr=10 exclusive_caps=1
  '';

  # Set your time zone.
  time.timeZone = "Asia/Tehran";
  boot.kernelParams = [
    "video=HDMI-A-1:1920x1080@75"
    "video=DP-2:1920x1080@75"
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.opengl = {
    driSupport = true; # This is already enabled by default
    driSupport32Bit = true; # For 32 bit applications
    extraPackages = with pkgs;
      [
        amdvlk # unfree alternative to RadV vulkan loader
      ];
    # For 32 bit applications 
    extraPackages32 = with pkgs;
      [
        driversi686Linux.amdvlk # unfree alternative to RadV vulkan loader
      ];
  };

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.settings.General.Experimental =
    true; # enables Bluetooth battery report
  hardware.bluetooth.powerOnBoot =
    true; # powers up the default Bluetooth controller on boot

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.splix ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mk = {
    isNormalUser = true;
    description = "mk";
    extraGroups = [ "networkmanager" "wheel" "dialout" "audio" ];
    packages = with pkgs; [ ];
  };
  # added user to trusted users 
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    lact # TODO: add the config file generated by lact here to lock the vram clock
    git
    wget
  ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lact.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
