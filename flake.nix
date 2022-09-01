{

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-22.05;
  };

  outputs = inputs@{ self,  nixpkgs, }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    configuration = import ./configuration.nix;
  in {

    packages.${system} = rec {
      auto-usb = (x: x.config.system.build.isoImage) (
        let usb-module = { pkgs, modulesPath, ...}: {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
              # (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")
              (modulesPath + "/installer/scan/not-detected.nix")];};
        in nixpkgs.lib.nixosSystem {
           inherit system;
           modules = [
             usb-module

             (
               { pkgs, lib, ...} : let
                   disk = "/dev/nvme0n1";
                 in {
                 # use the latest Linux kernel
                 boot.kernelPackages = pkgs.linuxPackages_latest;

                 # Needed for https://github.com/NixOS/nixpkgs/issues/58959
                 boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
                 boot.postBootCommands = ''

                  # Partitioning
                  sudo parted ${disk} -- mklabel gpt
                  sudo parted ${disk} -- mkpart primary 512MB -8GB
                  sudo parted ${disk} -- mkpart primary linux-swap -8GB 100%
                  sudo parted ${disk} -- mkpart ESP fat32 1MB 512MB
                  sudo parted ${disk} -- set 3 esp on

                  # Formatting
                  sudo mkfs.ext4 -L root ${disk}p1
                  sudo mkswap -L swap ${disk}p2
                  sudo mkfs.fat -F 32 -n BOOT ${disk}p3

                  # installing
                  sudo mount ${disk}p1 /mnt

                  sudo mkdir -p /mnt/boot
                  sudo mount ${disk}p3 /mnt/boot
                  sudo swapon ${disk}p2
                  nixos-install --flake ${./.} .#master
                 '';
               }
             )

           #   ({...}: {
           #   boot.initrd.preLVMCommands = ''
           #     ${self.packages.${system}.run-pixiecore}/bin/run-pixiecore
           #   '';
           # })
             # ({config, pkgs, ...} : {
             #    environment.systemPackages = with pkgs; [
             #      firefox
             #      vim
             #    ];
             # })
           ];
         });

      netboot = (x: x.netboot.${system})
        (import (nixpkgs.outPath + "/nixos/release.nix") {
          inherit configuration;
        });

      run-pixiecore = let
        kernel = "${netboot}/bzImage";
        initrd = "${netboot}/initrd";
        init = "$(grep -ohP 'init=\\S+' ${netboot}/netboot.ipxe)";
      in pkgs.writeScriptBin "run-pixiecore" ''
        echo ====== run-pixiecore ======
        sudo ${pkgs.pixiecore}/bin/pixiecore \
        boot ${kernel} ${initrd} \
        --cmdline "${init} loglevel=4"\
        --debug --dhcp-no-bind --port 52647 --status-port 52647

      '';
    };

    apps.${system} = {
      default = {
        type = "app";
        program = "${self.packages.${system}.run-pixiecore}/bin/run-pixiecore";
      };
    };

    nixosConfiguraions = {
      master = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({config, pkgs, ... } : {
            imports = [
              (import ./configuration.nix)
              (import ./hardware-configuration.nix)
            ];
          })
        ];
      };
    };
  };

}

