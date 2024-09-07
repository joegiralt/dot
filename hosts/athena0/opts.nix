{
  hostname = "athena0";
  lanAddress = "192.168.1.32";
  timeZone = "Europe/Madrid";
  adminUID = "1000";
  adminGID = "100";
  locale = "en_US.UTF-8";
  nameservers = [
    "9.9.9.9" # Quad9
    "149.112.112.112" # Quad9
    "194.242.2.5" # Mullvad
  ];

  paths = {
    app-data = "/mnt/data/appdata";
    app-data-archive = "/mnt/data/appdata/files";
    app-dbs = "/mnt/data/appdata/databases";
    app-dbs-archive = "/mnt/data/appdata/databases";
    audiobooks = "/mnt/data/media/audiobooks";
    books = "/mnt/data/media/books";
    documents = "/mnt/data/personal/documents";
    downloads = "/mnt/data/downloads";
    images = "/mnt/data/media/photos";
    llama-cpp-models = "/mnt/data/resources/llms/llama-cpp-models";
    magazines = "/mnt/data/media/magazines";
    film = "/mnt/data2/media/film";
    music = "/mnt/data/media/music";
    other = "/mnt/data/other";
    podcasts = "/mnt/data/media/podcasts";
    podman-socket = "/var/run/podman/podman.sock";
    qbt-images = "/mnt/data/media/photos/other";
    television = "/mnt/data2/media/shows";
    torrent-watch = "/mnt/data/downloads/torrents";
    videos = "/mnt/data2/media/videos";
  };

  ports = {
    audiobookshelf = "13378";
    filebrowser = "9008";
    flare-solverr = "8191";
    homer = "83";
  };

}
