{
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations = withSystem "x86_64-linux" ({
    system,
    config,
    self',
    pkgs,
    ...
  }: let
    systemInputs = {_module.args = {inherit inputs;};};
    inherit (inputs.nixpkgs.lib) nixosSystem;
    allowUnfree = {pkgs.config.allowUnfree = true;};
  in {
    s4rch = nixosSystem {
      inherit system;
      modules = [
        {
          imports = [./hardware-configuration.nix];
          users.users.s4rch = {
            isNormalUser = true;
            extraGroups = ["wheel" "docker" "networkmanager"];
          };
          nixpkgs.config.allowUnfree = true;
          nix.settings.experimental-features = ["nix-command" "flakes"];
          environment.systemPackages = with pkgs; [
            git
            curl
            wget
            ouch
            bluez
            flameshot
            ripgrep
            xdg-utils
            pavucontrol
            docker-compose
            font-manager
            wev
          ];
          programs.neovim.enable = true;
          programs.neovim.defaultEditor = true;

          programs.fish.enable = true;

          programs.hyprland.enable = true;

          networking.networkmanager.enable = true;
          services.xserver.displayManager.gdm.enable = true;

          boot.supportedFilesystems = ["btrfs"];
          boot.loader = {
            systemd-boot.enable = false;
            efi = {
              canTouchEfiVariables = true;
              efiSysMountPoint = "/boot";
            };
            grub = {
              enable = true;
              device = "nodev";
              efiSupport = true;
              useOSProber = true;
            };
          };

          sound.enable = true;
          services = {
            openssh = {
              enable = true;
              settings = {
                PasswordAuthentication = true;
                PermitRootLogin = "no";
              };
            };
            gnome.gnome-keyring.enable = true;
            pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              jack.enable = true;
              pulse.enable = true;
            };
          };
          virtualisation = {
            docker = {
              enable = true;
              enableOnBoot = true;
            };
          };
          xdg.portal = {
            enable = true;
            extraPortals = [pkgs.xdg-desktop-portal-gtk];
          };
        }
      ];
      specialArgs = {
        inherit inputs;
      };
    };
  });
}
