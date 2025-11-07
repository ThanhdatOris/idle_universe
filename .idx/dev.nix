{pkgs}: {
  channel = "stable-24.05";
  packages = [
    pkgs.jdk17
    pkgs.unzip
  ];
  idx.extensions = [
    "christian-kohler.path-intellisense"
    "Dart-Code.dart-code"
    "Dart-Code.flutter"
    "eamodio.gitlens"
    "formulahendry.auto-rename-tag"
    "Jaakko.black"
    "oderwat.indent-rainbow"
    "redhat.vscode-xml"
    "redhat.vscode-yaml"
    "shardulm94.trailing-spaces"
    "usernamehw.errorlens"
    "vscode-icons-team.vscode-icons"
    "yzhang.markdown-all-in-one"];

  idx.previews = {
    previews = {
      web = {
        command = [
          "flutter"
          "run"
          "--machine"
          "-d"
          "web-server"
          "--web-hostname"
          "0.0.0.0"
          "--web-port"
          "$PORT"
        ];
        manager = "flutter";
      };
      android = {
        command = [
          "flutter"
          "run"
          "--machine"
          "-d"
          "android"
          "-d"
          "localhost:5555"
        ];
        manager = "flutter";
      };
    };
  };
}