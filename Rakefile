require "etc"

def current_user
  @current_user ||= `whoami`.strip
end

def current_host
  @current_host ||= `hostname`.strip
end

def nix_jobs
  raw = ENV["NIX_JOBS"]
  return Integer(raw, exception: false) if raw && Integer(raw, exception: false).to_i > 0

  threads = Etc.nprocessors        # logical cpuss
  max_jobs = threads               # full blast
  min_jobs = [threads - 2, 1].max  # just a wee bit of headroom

  min_jobs
end

def nixos_flake_ref
  # .#hostname
  @nixos_flake_ref ||= ".##{current_host}"
end

def home_flake_ref
  # .#user@hostname
  @home_flake_ref ||= ".##{current_user}@#{current_host}"
end

namespace :nix do
  desc "format configuration"
  task :format do
    sh("nix fmt")
  end
  
  desc "show basic nix environment and config info"
    task :info do
    system_str = begin
      `nix eval --raw --impure --expr 'builtins.currentSystem' 2>/dev/null`.strip
    rescue
      "unknown"
    end

    nix_version = `nix --version 2>/dev/null`.strip
    nixos_version = if File.exist?("/etc/NIXOS")
      `nixos-version 2>/dev/null`.strip
    else
      "(not NixOS)"
    end

    hm_version = begin
      out = `home-manager --version 2>/dev/null`.strip
      out.empty? ? "(home-manager not found)" : out
    rescue
      "(home-manager not found)"
    end

    channels = begin
      out = `nix-channel --list 2>/dev/null`.strip
      out.empty? ? "(no user channels configured)" : out
    rescue
      "(nix-channel not available)"
    end

    registry = begin
      out = `nix registry list 2>/dev/null`.strip
      out.empty? ? "(no explicit flake registry entries)" : out
    rescue
      "(flake registry not available)"
    end

    show_config = begin
      `nix show-config 2>/dev/null`
    rescue
      ""
    end

    def pick_cfg(show_config, key)
      line = show_config.lines.grep(/^#{Regexp.escape(key)}\s*=/).first
      line ? line.strip : "#{key}=<not set>"
    end

    experimental = pick_cfg(show_config, "experimental-features")
    max_jobs     = pick_cfg(show_config, "max-jobs")
    cores        = pick_cfg(show_config, "cores")
    sandbox      = pick_cfg(show_config, "sandbox")
    substituters = pick_cfg(show_config, "substituters")
    store_dir    = pick_cfg(show_config, "store-dir")

    store_df = begin
      df_line = `df -h /nix/store 2>/dev/null`.lines[1]
      df_line ? df_line.split : []
    rescue
      []
    end

    puts "== Identity =="
    puts "User:          #{current_user}"
    puts "Host:          #{current_host}"
    puts

    puts "== Flakes =="
    puts "Flake (OS):    #{nixos_flake_ref}"
    puts "Flake (Home):  #{home_flake_ref}"
    puts "Nix jobs:      #{nix_jobs}"
    puts

    puts "== Versions =="
    puts "Nix version:   #{nix_version.empty? ? 'unknown' : nix_version}"
    puts "NixOS version: #{nixos_version}"
    puts "HM version:    #{hm_version}"
    puts "System:        #{system_str}"
    puts
    
    puts "== Substituters =="
    puts substituters.split(" ")[2..]
    puts

    puts "== Config (nix show-config) =="
    puts experimental
    puts max_jobs
    puts cores
    puts sandbox
  
    puts store_dir
    puts

    puts "== Channels =="
    puts channels.split(" ")
    puts

    puts "== Flake registry =="
    puts registry
    puts

    unless store_df.empty?
      dev, size, used, avail, percent, mount = store_df
      puts "== /nix/store disk usage =="
      puts "Device:        #{dev}"
      puts "Size:          #{size}"
      puts "Used:          #{used} (#{percent})"
      puts "Available:     #{avail}"
      puts "Mountpoint:    #{mount}"
      puts
    end
  end

  desc "take out the trash (GC, delete old generations)"
  task :gc do
    sh("nix-collect-garbage -d")
  end

  namespace :flake do
    desc "update nix flake.lock"
    task :update do
      sh("nix flake update --commit-lock-file")
    end

    desc "check nix flakes & configurations for current system (impure)"
    task :check do
      sh("nix flake check --impure")
    end

    namespace :check do
      desc "check nix flakes & configurations for all systems (impure)"
      task :all do
        sh("nix flake check --all-systems --impure")
      end
    end
  end

  namespace :os do
    namespace :install do
      desc "rebuild & install nixos configuration offline"
      task :offline do
        sh("nixos-rebuild switch --offline --flake '#{nixos_flake_ref}' --sudo --impure -j #{nix_jobs}")
      end
    end

    desc "rebuild & install nixos configuration"
    task :install do
      sh("nixos-rebuild switch --flake '#{nixos_flake_ref}' --sudo --impure -j #{nix_jobs}")
    end
  end

  namespace :home do
    desc "build home-manager activation package (no switch)"
    task :build do
      sh("nix build --impure '.#homeConfigurations.\"#{current_user}\".activationPackage'")
    end

    desc "rebuild & install home-manager config"
    task :install do
      sh("home-manager switch --impure --flake '#{home_flake_ref}' -j #{nix_jobs}")
    end

    namespace :install do
      desc "rebuild & install home-manager config offline"
      task :offline do
        sh("home-manager switch --impure --option substitute false --flake '#{home_flake_ref}' -j #{nix_jobs}")
      end

      desc "rebuild & install home-manager config and backup replaced files"
      task :backup do
        sh("home-manager switch --impure --flake '#{home_flake_ref}' -j #{nix_jobs} -b backup")
      end

      namespace :offline do
        desc "rebuild & install home-manager config offline and backup replaced files"
        task :backup do
          sh("home-manager switch --impure --option substitute false --flake '#{home_flake_ref}' -j #{nix_jobs} -b backup")
        end
      end
    end
  end
end

namespace :popos do
  desc "update all packages on Pop!_OS (apt)"
  task :update do
    sh("sudo apt update && sudo apt upgrade")
  end

  desc "remove unused packages on Pop!_OS (apt autoremove)"
  task :autoremove do
    sh("sudo apt autoremove")
  end
end

namespace :arch do
  desc "archive packages from arch/aur/flatpak/cargo"
  task :archive do
    sh("./bin/archive-packages")
  end

  desc "restore packages from arch/aur/flatpak/cargo"
  task :restore do
    sh("./bin/restore-packages")
  end
end
