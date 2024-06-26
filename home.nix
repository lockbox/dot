{ config, pkgs, ... }:

{
  # not ninxOS
  targets.genericLinux.enable = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "lockbox";
  home.homeDirectory = "/home/lockbox";

  # enable flakes and new command
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.git-lfs

    # It is sometimes useful to fine-tune packages, for example, by applying
    # overrides. You can do that directly here, just don't forget the
    # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # fonts?
    (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" "FiraMono" "SourceCodePro" ]; })

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
  #  /etc/profiles/per-user/lockbox/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # manage bash
  programs.bash = {
    enable = true;
    # for now drop into the venv
    bashrcExtra = ''
      if [ -f ~/v/bin/activate ]; then
        . ~/v/bin/activate
      fi
      if [ -f ~/.ghcup/env ]; then
        . ~/.ghcup/env
      fi
      alias ls=lsd
      alias docker-compose="docker compose"

      # if on gentoo box, add etckeeper hooks
      if [[ "$HOSTNAME" = "codeine" ]]; then

        # From /usr/share/doc/etckeeper*/bashrc.example
        case "$EBUILD_PHASE" in
          setup|prerm) etckeeper pre-install ;;
          postinst|postrm) etckeeper post-install ;;
        esac
      fi

      # add zoxide hooks
      eval "$(zoxide init bash)"
    '';
  };


  # gotta love FOSS weenies: https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  imports = [
    ./modules
  ];
}
