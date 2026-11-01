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

# asusd is a root daemon, which home-manager can't install on Pop!_OS. Build the
# same asusctl home-manager uses, keep it GC-rooted, and copy its system files
# (which reference the store path) into /etc.
namespace :asusd do
  ASUSD_ROOT = File.join(Dir.home, ".local/state/asusctl-system")
  ASUSD_FILES = {
    "lib/systemd/system/asusd.service" => "/etc/systemd/system/asusd.service",
    "lib/systemd/system/asus-shutdown.service" => "/etc/systemd/system/asus-shutdown.service",
    "lib/udev/rules.d/99-asusd.rules" => "/etc/udev/rules.d/99-asusd.rules",
    "share/dbus-1/system.d/asusd.conf" => "/etc/dbus-1/system.d/asusd.conf",
  }.freeze

  # Left behind by the old `make install` from ~/asusctl (6.1.17).
  ASUSD_LEGACY = %w[
    /usr/bin/asusd /usr/bin/asusctl /usr/bin/asusd-user /usr/bin/rog-control-center
    /usr/lib/systemd/system/asusd.service /usr/lib/systemd/user/asusd-user.service
    /usr/lib/udev/rules.d/99-asusd.rules /usr/share/dbus-1/system.d/asusd.conf
    /usr/share/applications/rog-control-center.desktop
    /usr/share/icons/hicolor/512x512/apps/rog-control-center.png
    /usr/share/icons/hicolor/512x512/apps/asus_notif_blue.png
    /usr/share/icons/hicolor/512x512/apps/asus_notif_green.png
    /usr/share/icons/hicolor/512x512/apps/asus_notif_orange.png
    /usr/share/icons/hicolor/512x512/apps/asus_notif_red.png
    /usr/share/icons/hicolor/512x512/apps/asus_notif_white.png
    /usr/share/icons/hicolor/512x512/apps/asus_notif_yellow.png
    /usr/share/icons/hicolor/scalable/status/gpu-compute.svg
    /usr/share/icons/hicolor/scalable/status/gpu-hybrid.svg
    /usr/share/icons/hicolor/scalable/status/gpu-integrated.svg
    /usr/share/icons/hicolor/scalable/status/gpu-nvidia.svg
    /usr/share/icons/hicolor/scalable/status/gpu-vfio.svg
    /usr/share/icons/hicolor/scalable/status/notification-reboot.svg
    /usr/share/asusd /usr/share/rog-gui /usr/share/asusctl
  ].freeze

  desc "build asusctl and install asusd system files into /etc (sudo)"
  task :install do
    sh("nix build '.#asusctl' --out-link '#{ASUSD_ROOT}' -j #{nix_jobs}")
    store = File.realpath(ASUSD_ROOT)

    ASUSD_FILES.each do |src, dest|
      sh("sudo install -D -m 0644 '#{store}/#{src}' '#{dest}'")
    end

    sh("sudo systemctl daemon-reload")
    sh("sudo udevadm control --reload")
    sh("sudo systemctl reload dbus")
    sh("sudo systemctl restart asusd")
    sh("systemctl status asusd --no-pager --lines=5")
  end

  desc "remove the old make-install asusctl from /usr (one-time, sudo)"
  task :remove_legacy do
    if File.directory?("/etc/asusd") && !File.exist?("/etc/asusd.bak")
      sh("sudo cp -a /etc/asusd /etc/asusd.bak")
    end

    ASUSD_LEGACY.select { |p| File.exist?(p) }.each do |path|
      owned = system("dpkg -S '#{path}'", out: File::NULL, err: File::NULL)
      next puts("skipping #{path}: owned by a dpkg package") if owned

      sh("sudo rm -rf '#{path}'")
    end

    sh("sudo systemctl daemon-reload")
  end
end

namespace :podman do
  desc "Pull all tagged local podman images"
  task :pull do
    sh <<~SH
      podman images --format '{{.Repository}}:{{.Tag}}' |
        grep -v '<none>' |
        sort -u |
        xargs -n1 sh -c 'podman pull "$1" || true' sh
    SH
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
    tailscale_status_json
      .then { |json| json.fetch("ExitNodeStatus", {}) }
      .then { |s| s["HostName"] || s["DNSName"] || s["ID"] }
      .then do |name|
        next unless name
        EXIT_NODE_MAP.find { |_, cfg| name.include?(cfg[:match]) }&.first
      end
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
    keys    = EXIT_NODE_MAP.keys
    current = current_exit_node_label
  
    next_key =
      keys
        .then { |ks| ks.rotate(ks.index(current).to_i + 1) }
        .first
  
    cfg = EXIT_NODE_MAP.fetch(next_key)
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
