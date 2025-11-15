{ config, pkgs, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # General layout:
      # first line: path + git + langs + nix shell + (maybe) cmd duration
      # second line: prompt character
      add_newline = true;
      format = "$directory$git_branch$git_status$nodejs$python$ruby$elixir$rust$nix_shell$cmd_duration\n$character\n";

      # --- Directory ---
      directory = {
        style = "bold blue";
        truncation_length = 2; # keep last 2 components: …/etl/app
        truncate_to_repo = true; # don't truncate inside a git repo root
      };

      # --- Git branch ---
      git_branch = {
        format = " [$symbol$branch]($style) ";
        symbol = " ";
        style = "bold purple";
      };

      # --- Git status (compact) ---
      git_status = {
        conflicted = "✖";
        ahead = "⇡";
        behind = "⇣";
        staged = "+";
        modified = "!";
        untracked = "?";
        stashed = "⧉";
        style = "yellow";
        format = "$all_status";
      };

      # --- Nix shell indicator ---
      nix_shell = {
        format = " via [$state]($style)";
        style = "cyan bold";
      };

      # --- Command duration (only if slow) ---
      cmd_duration = {
        min_time = 2000; # ms; only show if > 2s
        format = " took [$duration]($style)";
        style = "bold yellow";
      };

      # --- Prompt character (no emoji garbage) ---
      character = {
        success_symbol = "❯";
        error_symbol = "❯";
        vicmd_symbol = "❮";
      };

      # --- Time (kept disabled, but configured) ---
      time = {
        disabled = true;
        time_format = "%H:%M:%S";
        style = "dimmed blue";
      };

      # --- Node.js ---
      nodejs = {
        detect_files = [
          "package.json"
          ".nvmrc"
          "node_modules"
        ];
        detect_folders = [ "node_modules" ];
        format = " [nodejs]($style)";
        style = "green bold";
      };

      # --- Python ---
      python = {
        detect_files = [
          "pyproject.toml"
          "requirements.txt"
          "Pipfile"
        ];
        format = " [py]($style)";
        style = "yellow bold";
      };

      # --- Rust ---
      rust = {
        detect_files = [ "Cargo.toml" ];
        detect_extensions = [ "rs" ];
        format = " [🦀 - Hello Rustacean!]($style)";
        style = "red bold";
      };
      
      # --- Nix ---
      custom = {
        nix = {
          command = "echo nix";
          when = "test -f flake.nix || test -f default.nix || test -d nix";
          format = " [$output]($style)";
          style = "green bold";
        };
      };

      # --- Ruby ---
      ruby = {
        detect_files = [
          "Gemfile"
          ".ruby-version"
        ];
        detect_folders = [ "gem" ];
        format = " [♦️ hello Rubyist!]($style)";
        style = "red bold";
      };

      # --- Elixir ---
      elixir = {
        detect_files = [ "mix.exs" ];
        format = " [elixir]($style)";
        style = "purple bold";
      };

      # --- Docker / Podman context ---
      docker_context = {
        format = " docker:[$context]($style)";
        style = "blue bold";
        disabled = false;
      };
    };
  };
}
