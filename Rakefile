# nix info stuffs
require "etc"

# tailscale
require "open3"
require "json"
require "fileutils"

def current_user
  @current_user ||= `whoami`.strip
end

def current_host
  @current_host ||= `hostname`.strip
end

def nix_jobs
  raw = ENV["NIX_JOBS"]
  return Integer(raw, exception: false) if raw && Integer(raw, exception: false).to_i > 0

  threads = Etc.nprocessors        # logical cpus
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

namespace :tailscale do
  # alias => { host: value passed to tailscale set, match: substring to detect in status }
  EXIT_NODE_MAP = {
    # Iberia / nearby EU
    "bcn" => { host: "es-bcn-wg-001.mullvad.ts.net", match: "es-bcn-wg-001" },
    "mad" => { host: "es-mad-wg-201.mullvad.ts.net", match: "es-mad-wg-201" },
    "lis" => { host: "pt-lis-wg-201.mullvad.ts.net", match: "pt-lis-wg-201" },
    
    # Core EU
    "par" => { host: "fr-par-wg-001.mullvad.ts.net", match: "fr-par-wg-001" },
    "fra" => { host: "de-fra-wg-001.mullvad.ts.net", match: "de-fra-wg-001" },
    "ams" => { host: "nl-ams-wg-001.mullvad.ts.net", match: "nl-ams-wg-001" },
    "ber" => { host: "de-ber-wg-001.mullvad.ts.net", match: "de-ber-wg-001" },
    "zrh" => { host: "ch-zrh-wg-201.mullvad.ts.net", match: "ch-zrh-wg-201" },

    # UK
    "lon" => { host: "gb-lon-wg-001.mullvad.ts.net", match: "gb-lon-wg-001" },
    "man" => { host: "gb-mnc-wg-201.mullvad.ts.net", match: "gb-mnc-wg-201" },

    # US
    "nyc" => { host: "us-nyc-wg-301.mullvad.ts.net", match: "us-nyc-wg-301" },
    "lax" => { host: "us-lax-wg-101.mullvad.ts.net", match: "us-lax-wg-101" },
    "chi" => { host: "us-chi-wg-301.mullvad.ts.net", match: "us-chi-wg-301" },
    "sea" => { host: "us-sea-wg-001.mullvad.ts.net", match: "us-sea-wg-001" },
    "mia" => { host: "us-mia-wg-002.mullvad.ts.net", match: "us-mia-wg-002" },

    # Far East / APAC
    "tyo" => { host: "jp-tyo-wg-001.mullvad.ts.net", match: "jp-tyo-wg-001" },
    "osa" => { host: "jp-osa-wg-001.mullvad.ts.net", match: "jp-osa-wg-001" },
    "sin" => { host: "sg-sin-wg-001.mullvad.ts.net", match: "sg-sin-wg-001" },
    "hkg" => { host: "hk-hkg-wg-201.mullvad.ts.net", match: "hk-hkg-wg-201" },
    "kul" => { host: "my-kul-wg-001.mullvad.ts.net", match: "my-kul-wg-001" },
  }.freeze

  HEALTH_STATE = "/var/lib/tailscale-exit-health".freeze
  LAST_CYCLE   = "#{HEALTH_STATE}/last_cycle".freeze
  COOLDOWN_SEC = 30 * 60   # 30 minutes

  def tailscale_status_json
    out, _ = Open3.capture2("tailscale status --json")
    JSON.parse(out)
  rescue => e
    warn "Failed to parse tailscale status JSON: #{e.class}: #{e.message}"
    {}
  end

  def current_exit_node_label
    data = tailscale_status_json
    s = data.fetch("ExitNodeStatus", {})

    # try HostName, then DNSName, then ID as last resort
    name = s["HostName"] || s["DNSName"] || s["ID"]
    return nil unless name

    # find which alias matches this name by substring
    EXIT_NODE_MAP.each do |alias_name, cfg|
      return alias_name if name.include?(cfg[:match])
    end

    nil
  end

  # runs a shell command, returns true/false
  def sh_ok?(cmd)
    system(cmd, out: File::NULL, err: File::NULL)
  end

  # simple connectivity tests
  def healthy?
    return false unless sh_ok?("ping -c1 -W1 1.1.1.1")
    return false unless sh_ok?("ping -c1 -W1 8.8.8.8")
    return false unless sh_ok?("curl -4 --silent --max-time 5 https://github.com")

    true
  end

  def cooldown_expired?
    FileUtils.mkdir_p(HEALTH_STATE)
    return true unless File.exist?(LAST_CYCLE)

    last = File.read(LAST_CYCLE).to_i
    now  = Time.now.to_i

    (now - last) >= COOLDOWN_SEC
  end

  def record_cycle!
    FileUtils.mkdir_p(HEALTH_STATE)
    File.write(LAST_CYCLE, Time.now.to_i.to_s)
  end

  desc "Check Tailscale connectivity; auto-cycle exit node if bad (for systemd)"
  task :auto_health do
    unless cooldown_expired?
      puts "Cooldown active. Skipping."
      next
    end

    if healthy?
      puts "Tailscale connection OK. No action."
      next
    end

    puts "Connectivity bad. Cycling exit node…"
    Rake::Task["tailscale:cycle"].invoke
    record_cycle!
  end

  desc "Show Tailscale status including current exit node"
  task :status do
    sh("tailscale status")
  end

  desc "Clear exit node (return to direct WAN)"
  task :clear do
    sh("sudo tailscale set --exit-node=")
  end

  desc "Use an exit node alias. Example: rake 'tailscale:use[bcn]'"
  task :use, [:alias] do |_t, args|
    key = args[:alias]
    unless key && EXIT_NODE_MAP.key?(key)
      puts "Valid aliases: #{EXIT_NODE_MAP.keys.join(', ')}"
      abort "Unknown alias: #{key.inspect}"
    end

    cfg = EXIT_NODE_MAP[key]
    puts "Switching exit node to #{key} (#{cfg[:host]})"
    sh("sudo tailscale set --exit-node=#{cfg[:host]} --exit-node-allow-lan-access=true")
  end

  desc "Cycle to next exit node in alias order"
  task :cycle do
    keys = EXIT_NODE_MAP.keys
    current = current_exit_node_label

    if current
      idx = keys.index(current) || 0
      next_key = keys[(idx + 1) % keys.length]
    else
      # If we can't detect, start at the first
      next_key = keys.first
      warn "Could not detect current exit node; defaulting to #{next_key}"
    end

    cfg = EXIT_NODE_MAP[next_key]
    puts "Cycling exit node → #{next_key} (#{cfg[:host]})"
    sh("sudo tailscale set --exit-node=#{cfg[:host]} --exit-node-allow-lan-access=true")
  end

  desc "Ping via current exit node to check tunnel health"
  task :health, [:target] do |_t, args|
    target = args[:target] || "8.8.8.8"
    sh("ping -c3 #{target}")
  end

  desc "Debug: show JSON ExitNodeStatus"
  task :debug_status do
    data = tailscale_status_json
    puts JSON.pretty_generate(data.fetch("ExitNodeStatus", {}))
  end
end
