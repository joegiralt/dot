{ config, pkgs, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # General layout:
      # first line: user/host (if remote) + dir + git + langs + nix + env info
      # second line: prompt character
      add_newline = true;
      format = "$username$hostname$directory$git_branch$git_status$nodejs$python$ruby$elixir$rust$nix_shell$battery$cmd_duration$status$jobs\n$character\n";

      ########################
      # Core prompt pieces   #
      ########################

      directory = {
        style = "bold blue";
        truncation_length = 2;
        truncate_to_repo = true;
        home_symbol = "~";
        format = " :: [$path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        format = "on [$symbol$branch]($style) ";
        symbol = "🌱 ";
        style = "bold purple";
      };

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

      nix_shell = {
        format = " via [$state]($style)";
        style = "cyan bold";
      };

      cmd_duration = {
        min_time = 2000; # ms; only show if > 2s
        format = " took [$duration]($style)";
        style = "bold yellow";
      };

      status = {
        disabled = false;
        format = " [✖ $status]($style)";
        style = "bold red";
        pipestatus = true;
      };

      jobs = {
        threshold = 1;
        format = " [$symbol$number]($style)";
        symbol = "✦";
        style = "bold blue";
      };

      character = {
        success_symbol = "[λ](bold yellow) ";
        error_symbol = "[✗](bold red)";
        vicmd_symbol = "❮";
      };

      time = {
        disabled = true;
        time_format = "%H:%M:%S";
        style = "dimmed blue";
      };

      ########################
      # Lang / stack bits    #
      ########################

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

      python = {
        detect_files = [
          "pyproject.toml"
          "requirements.txt"
          "Pipfile"
        ];
        format = " [py]($style)";
        style = "yellow bold";
      };

      rust = {
        detect_files = [ "Cargo.toml" ];
        detect_extensions = [ "rs" ];
        format = " [🦀 - Hello Rustacean!]($style)";
        style = "green bold";
      };

      ruby = {
        detect_files = [
          "Gemfile"
          ".ruby-version"
        ];
        detect_folders = [
          "gems"
          "vendor/bundle"
        ];
        format = " [rb]($style)";
        style = "red bold";
      };

      elixir = {
        detect_files = [ "mix.exs" ];
        format = " [ex]($style)";
        style = "purple bold";
      };

      ########################
      # Env / context bits   #
      ########################

      docker_context = {
        format = " docker:[$context]($style)";
        style = "blue bold";
        disabled = false;
      };

      battery = {
        disabled = false;
        full_symbol = "🔋";
        charging_symbol = "🔌";
        discharging_symbol = "🪫";

        display = [
          {
            threshold = 20;
            style = "bold red";
          }
          {
            threshold = 50;
            style = "bold yellow";
          }
        ];
      };

      username = {
        show_always = true; # only show when it matters (root/ssh)
        style_user = "bold green";
        style_root = "bold red";
        format = "[$user]($style)";
      };

      hostname = {
        # ssh_only = true;
        format = "[@$hostname]($style) ";
        style = "bold green";
      };
    };
  };
}
