# use `nix flake update --flake ~/dotfiles/.config/home-manager` to pull in new available versions like apt-get update
# use `home-manager switch` to apply changes this file
# use `nix search nixpkgs spotify` to find a term in all packages/descriptions
# use `nix search nixpkgs#vscode .` to find a specific package
# use `home-manager -n expire-generations '-30 days'` to clean up old generations. remove -n dry run flag
# `home-manager packages` will list what you have installed like dpkg -l
# `nix run nixpkgs#cowsay -- "Hello, world!"` will temp run cowsay with input options without actually installing
# `nix shell nixpkgs#cowsay` will temp run cowsay in a shell without actually installing
{ config, pkgs, lib, ... }:

let

  # should pass isWork in as an extraArgs, hard coding for now
  #isWork = config.specialArgs.isWork or false;
  isWork = true;
  # This is debugging that doesnt work yet
  #_ = builtins.trace "extraSpecialArgs: ${toString config}" "";
  #_ = builtins.trace "Config contents: ${builtins.toJSON config}" null;


  commonPackages = with pkgs; [
    _1password-cli
    bat
    btop
    eza
    fd # A find tool, not sure what I actually use it for. seems useful enough
    fzf
    highlight
    jq
    lazygit
    lazysql  # still playing with this. not sure I want it
    neovim
    ripgrep
    shellcheck
    slack
    spotify
    tree
    trippy
    tmux
    yazi
    yubikey-manager

    # fonts
    nerd-fonts.monaspace
    nerd-fonts.meslo-lg

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];


  macOnlyPackages = with pkgs; [
    #_1password-gui # doesnt allow integration to browser and is "broken" package
    #brave          # not installing here so the 1password integration works
    #ghostty        # currently at 1.0.1 and is flagged as broken on mac and may never get fixed?
    # ---- pkgs above are not really mac only but did merrit some comments as to why they are not installed
    #ice-bar        # kinda buggy and crashes
    #beekeeper-studio # not supported on mac via nix
    #colima         # its the stupid docker server itself for m1 and is really work only
    maccy           # clipboard manager
    raycast         # spotlight replacement, how I do app hotkey navigation may try karabiner
    shortcat        # keyboard mouse navigations
    sketchybar      # might try simple-bar instead?
  ];

  # Extra packages I'll likely only use on systems I use for work
  workPackages = with pkgs; [
    dbeaver-bin  # meh.. work related not impressed by the bloat
    #docker
    #docker-client
    #dockerfile-language-server-nodejs # for LSP
    #docker-compose-language-service # for LSP
    #lazydocker
    nodejs # needed for stupid LSPs
    #nodejs-slim # needed for stupid LSPs probably better since its 'slim'.. need to test it tho
    telegram-desktop
    php # for LSPs and maybe more
    php82Extensions.xdebug
    postman
    newman
    python3Minimal
    puppet-lint # for LSP
    virtualenv
    vscode
    # zoom-us  # Disabled for now since it has issues when sharing screens, permissions?
  ];

in
{
  # Shouldnt need lib.flatten but it fixes issues
  home.packages = lib.flatten (commonPackages
    ++ (lib.optional pkgs.stdenv.isDarwin macOnlyPackages)
    ++ (lib.optional isWork workPackages));

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  # This is to ensure programs are using ~/.config
  # NOTE: is this already in my zsh/bash rc files?
  xdg.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This copies applications to top level /Apps dir so Spotlight finds them
  # should only run on macs
  home.activation.postInstallScript = lib.optionalString pkgs.stdenv.isDarwin (lib.mkAfter ''
    echo "setting up /Applications links..." >&2
    rm -rf /Applications/Nix-Apps
    mkdir -p /Applications/Nix-Apps
    find ~/Applications/Home\ Manager\ Apps/* -maxdepth 1 -type l -exec readlink '{}' + |
    while read -r src; do
      app_name=$(basename "$src")
      echo "copying $src" >&2
      # NOTE: I wanted mkalias to work but spotlight doesnt like it.. had to copy the dang things
      #${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix-Apps/$app_name"
      cp -r "$src" "/Applications/Nix-Apps/$app_name"
    done
    chmod -R u+w /Applications/Nix-Apps
  '');


}
