{ pkgs, username, ... }: {
  home.packages = with pkgs; [
    amfora
    aria2
    asciinema
    asciinema-agg
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    atuin
    babashka
    bat
    beanstalkd
    bingrep
    broot
    btop
    cava
    clang
    cmake
    cmatrix
    csvlens
    dig
    direnv
    duf
    dust
    exiftool
    eza
    fastfetch
    fd
    fzf
    git
    git-crypt
    git-filter-repo
    git-sizer
    gitleaks
    gperf
    gping
    grex
    hex
    hexyl
    html-tidy
    httpie
    hyperfine
    id3v2
    imagemagick
    ipcalc
    jaq
    jq
    less
    lf
    lua
    luau
    mediainfo
    mosh
    nasm
    ncdu
    netcat-gnu
    nettools
    nmap
    ouch
    p7zip
    pass
    procs
    progress
    pwgen
    python311Packages.eyed3
    restic
    ripgrep
    ripgrep-all
    rsync
    sc-im
    sshfs
    starship
    tailspin
    tokei
    traceroute
    tree
    tty-clock
    uiua
    unrar
    wget
    xh
    xxd
    yq
    zellij
    zoxide
  ];
}
