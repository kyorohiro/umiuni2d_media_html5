import 'package:umiuni2d_media_html5/umiuni2d_media.dart' as umi;
import 'dart:async';
import 'dart:html' as html;

Future main() async {
  print("Hellom World!!");
  umi.MediaManager mediaManager = new umi.MediaManager(
      "/web/assets");
  await mediaManager.loadAudioPlayer(
      "bgm_maoudamashii_acoustic09", "/bgm_maoudamashii_acoustic09.ogg");
  await mediaManager.loadAudioPlayer(
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
    mediaManager.getAudioPlayer(getCurrentPlayerId()).play();
  });

  html.document
      .querySelector("#Pause")
      .onClick
      .listen((html.Event e) {
    print("Pause");
    mediaManager.getAudioPlayer(getCurrentPlayerId()).pause();
  });
  html.document
      .querySelector("#Load")
      .onClick
      .listen((html.Event e) {
    print("Load");
    mediaManager.getAudioPlayer(getCurrentPlayerId()).prepare();
  });
  html.document
      .querySelector("#Stop")
      .onClick
      .listen((html.Event e) {
    print("Stop");
    mediaManager.getAudioPlayer(getCurrentPlayerId()).stop();
  });
  html.document
      .querySelector("#plus5s")
      .onClick
      .listen((html.Event e) async {
    print("+5s");

    double currentSec = await mediaManager.getAudioPlayer(getCurrentPlayerId()).getCurrentTime();
    mediaManager.getAudioPlayer(getCurrentPlayerId()).seek(currentSec + 5);
  });
  html.document
      .querySelector("#minus5s")
      .onClick
      .listen((html.Event e) async {
    print("-5s");
    double currentSec = await mediaManager.getAudioPlayer(getCurrentPlayerId()).getCurrentTime();
    mediaManager.getAudioPlayer(getCurrentPlayerId()).seek(currentSec - 5);
  });
  html.document
      .querySelector("#VolumeUp")
      .onClick
      .listen((html.Event e) async {
    print("VolumeUp");
    double currentVolume = await mediaManager.getAudioPlayer(getCurrentPlayerId()).getVolume();
    mediaManager.getAudioPlayer(getCurrentPlayerId()).setVolume(currentVolume+0.1);
  });
  html.document
      .querySelector("#VolumeDown")
      .onClick
      .listen((html.Event e) async {
    print("VolumeDown");
    double currentVolume = await mediaManager.getAudioPlayer(getCurrentPlayerId()).getVolume();
    mediaManager.getAudioPlayer(getCurrentPlayerId()).setVolume(currentVolume-0.1);
  });
}

