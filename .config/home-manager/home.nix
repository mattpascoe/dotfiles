# use `nix flake update --flake ~/dotfiles/.config/home-manager` to pull in new available versions
# use `home-manager switch` to apply changes this file
{ config, pkgs, lib, ... }:


{

  # Allow unfree packages, MDP: I think this should live in the flake?
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  #home.username = "mdp";
  #home.homeDirectory = "/Users/mdp";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  #home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    #_1password-gui # doesnt allow integration to browser and is "broken" package
    _1password-cli
    #beekeeper-studio # MAC only but, not supported on mac via nix
    #brave -- not installing here so the 1password integration works
    btop
    colima # Mac only, its the stupid docker server itself
    docker
    docker-client
    dockerfile-language-server-nodejs # for LSP
    docker-compose-language-service # for LSP
    fd
    fzf
    highlight
    ice-bar # Mac only menu bar
    jq
    lazydocker
    lazygit
    lazysql
    maccy  # mac only
    #mkalias # mac only, to fix spotlight finding apps
    neovim
    newman
    nodejs # needed for stupid LSPs
    #nodejs-slim # needed for stupid LSPs probably better since its 'slim'.. need to test it tho
    php # for LSPs and maybe more
    php82Extensions.xdebug
    postman
    puppet-lint # for LSP
    raycast # mac only
    ripgrep
    shellcheck
    sketchybar # Mac only
    slack
    telegram-desktop
    tree
    #trippy
    tmux
    python3Minimal
    virtualenv
    vscode
    yazi
    yubikey-manager
    zoom-us

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    #(pkgs.nerdfonts.override { fonts = [ "Monaspace" "Meslo" ]; })
    nerd-fonts.monaspace
    nerd-fonts.meslo-lg


    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mdp/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "vi";
  };

  # This is to ensure programs are using ~/.config rather than
  # /Users/<username/Library/whatever
  xdg.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This copies applications to top level /Apps dir so Spotlight finds them
  home.activation.postInstallScript = lib.mkAfter ''
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
  '';
}


