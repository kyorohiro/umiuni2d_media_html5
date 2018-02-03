library umiuni2d_media_html5;

import 'dart:async';
import 'dart:math'as math;
import 'dart:html';
import 'dart:web_gl';
import 'dart:web_audio';
import 'dart:typed_data';
import 'dart:convert' as conv;


class MediaManager {
  String assetsRoot;
  MediaManager(this.assetsRoot) {
  }

  Map<String, AudioPlayer> _audioMap = {};
  Future<AudioPlayer> loadAudio(String playerId, String path) async {
    String url = "${assetsRoot}${path}";
    AudioPlayer player = new AudioPlayer(playerId, url);
    await player.load();
    _audioMap[playerId] = player;
    return player;
  }

  AudioPlayer getAudio(String id) {
    return _audioMap[id];
  }
}

class AudioPlayer {
  AudioContext context;
  AudioBuffer buffer;
  AudioBufferSourceNode sourceNode = null;
  GainNode gain;

  String id;
  String url;
  double pauseAt = 0.0;
  double startAt = 0.0;
  bool isStart = false;

  AudioPlayer(this.id, this.url) {
    context = new AudioContext();
  }

  Future load() async {
    pauseAt = 0.0;
    startAt = 0.0;
    Completer<String> c = new Completer();
    HttpRequest request = new HttpRequest();
    request.responseType = "arraybuffer";
    request.onLoad.listen((ProgressEvent e) async {
      try {
        buffer = await context.decodeAudioData(request.response);
        c.complete("");
      } catch(e) {
        c.completeError(e);
      }
    });
    request.onError.listen((ProgressEvent e) {
      c.completeError(e);
    });

    request.open("GET", url);
    request.send();
    return c.future;
  }

  Future prepare() async {}

  Future<double> getCurentTime() async {
    double t = 0.0;
    if(isStart) {
      t = context.currentTime - startAt;
    } else {
      t = pauseAt;
    }
    return t;
  }

  Future<String> seek(double currentTime) async {
   // print("#A>># ${currentTime}");
    if(currentTime <0) {
      currentTime = 0.0;
    }
    if(isStart == false) {
      pauseAt = currentTime;
    } else {
      await start(currentTime: currentTime);
    }
  }

  Future start({double currentTime=null}) async {
    await pause();
    if(currentTime == null) {
    } else {
      pauseAt = currentTime;
    }
    sourceNode = context.createBufferSource();
    gain = context.createGain();
    sourceNode.connectNode(gain);

    gain.connectNode(context.destination);
    sourceNode.buffer = buffer;
    gain.gain.value = 0.5;//volume;
    sourceNode.connectNode(context.destination);
    sourceNode.start(0, pauseAt);
    print("#start ${pauseAt.toInt()}");

    isStart = true;
    startAt = context.currentTime - pauseAt ;
  }

  Future pause() async {
    if (sourceNode != null) {
      if(isStart == true) {
        pauseAt = context.currentTime - startAt;
      }
      sourceNode.stop(0);
      isStart = false;
    }
  }

  double _volume = 0.5;
  Future<double> getVolume() async => _volume;
  void setVolume(double v) {
    _volume = v;
    gain.gain.value = v;
  }
}