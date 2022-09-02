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
              (modulesPath + "/installer/scan/not-detected.nix")];};
        in nixpkgs.lib.nixosSystem {
           inherit system;
           modules = [
             usb-module
             ({...}: {
             boot.initrd.preLVMCommands = ''
               ${self.packages.${system}.run-pixiecore}/bin/run-pixiecore
             '';
           })];
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
  };

}
