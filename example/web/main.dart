import 'package:umiuni2d_media_html5/umiuni2d_media.dart' as umi;
import 'dart:async';
import 'dart:html' as html;

Future main() async {
  print("Hellom World!!");
  umi.MediaManager mediaManager = new umi.MediaManager(
      "/web/assets");
  await mediaManager.loadAudio(
      "bgm_maoudamashii_acoustic09", "/bgm_maoudamashii_acoustic09.ogg");
  await mediaManager.loadAudio(
      "bgm_maoudamashii_lastboss0", "/bgm_maoudamashii_lastboss0.ogg");

  String getCurrentPlayerId() {
    if ((html.document.querySelector(
        "#bgm_maoudamashii_acoustic09") as html.InputElement).checked) {
      return "bgm_maoudamashii_acoustic09";
    } else {
      return "bgm_maoudamashii_lastboss0";
    }
  };

  //player.start();
  html.document
      .querySelector("#Play")
      .onClick
      .listen((html.Event e) {
    print("Play ${getCurrentPlayerId()}" );
    mediaManager.getAudio(getCurrentPlayerId()).play();
  });

  html.document
      .querySelector("#Pause")
      .onClick
      .listen((html.Event e) {
    print("Pause");
    mediaManager.getAudio(getCurrentPlayerId()).pause();
  });
  html.document
      .querySelector("#Load")
      .onClick
      .listen((html.Event e) {
    print("Load");
  });
  html.document
      .querySelector("#Stop")
      .onClick
      .listen((html.Event e) {
    print("Stop");
  });
  html.document
      .querySelector("#plus5s")
      .onClick
      .listen((html.Event e) async {
    print("+5s");

    double volume = await mediaManager.getAudio(getCurrentPlayerId()).getCurrentTime();
    mediaManager.getAudio(getCurrentPlayerId()).seek(volume + 5);
  });
  html.document
      .querySelector("#minus5s")
      .onClick
      .listen((html.Event e) async {
    print("-5s");
    double volume = await mediaManager.getAudio(getCurrentPlayerId()).getCurrentTime();
    mediaManager.getAudio(getCurrentPlayerId()).seek(volume - 5);
  });
  html.document
      .querySelector("#VolumeUp")
      .onClick
      .listen((html.Event e) async {
    print("VolumeUp");
    double currentVolume = await mediaManager.getAudio(getCurrentPlayerId()).getVolume();
    mediaManager.getAudio(getCurrentPlayerId()).setVolume(currentVolume+0.1);
  });
  html.document
      .querySelector("#VolumeDown")
      .onClick
      .listen((html.Event e) async {
    print("VolumeDown");
    double currentVolume = await mediaManager.getAudio(getCurrentPlayerId()).getVolume();
    mediaManager.getAudio(getCurrentPlayerId()).setVolume(currentVolume-0.1);
  });
}

