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
  Future<AudioPlayer> loadAudioPlayer(String playerId, String path) async {
    String url = "${assetsRoot}${path}";
    AudioPlayer player = new AudioPlayer(playerId, url);
    await player.prepare();
    _audioMap[playerId] = player;
    return player;
  }

  Future<AudioPlayer> createAudio(String playerId, String path) async {
    String url = "${assetsRoot}${path}";
    AudioPlayer player = new AudioPlayer(playerId, url);
    _audioMap[playerId] = player;
    return player;
  }

  AudioPlayer getAudioPlayer(String id) {
    return _audioMap[id];
  }
}

class AudioPlayer {
  AudioContext _context;
  AudioBuffer _buffer;
  AudioBufferSourceNode _sourceNode;
  GainNode _gain;

  String _playerId;
  String get plyerId => _playerId;
  String _url;
  String get url => _url;

  double _pauseAt = 0.0;
  double _startAt = 0.0;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  bool _isPrepared = false;
  bool get isPrepared => _isPrepared;
  double _volume = 0.5;

  AudioPlayer(this._playerId, this._url, {double volume=0.5}) {
    _volume = volume;
  }

  Future<AudioPlayer> prepare() async {
    _pauseAt = 0.0;
    _startAt = 0.0;
    _context = new AudioContext();
    Completer<AudioPlayer> c = new Completer();
    HttpRequest request = new HttpRequest();
    request.responseType = "arraybuffer";
    request.onLoad.listen((ProgressEvent e) async {
      try {
        _buffer = await _context.decodeAudioData(request.response);
        _isPrepared = true;
        c.complete(this);
      } catch(e) {
        _isPrepared = false;
        c.completeError(e);
      }
    });

    request.onError.listen((ProgressEvent e) {
      c.completeError(e);
    });

    request.open("GET", _url);
    request.send();
    return c.future;
  }

  Future<double> getCurrentTime() async {
    double t = 0.0;
    if(_isPlaying) {
      t = _context.currentTime - _startAt;
    } else {
      t = _pauseAt;
    }
    return t;
  }

  Future<AudioPlayer> seek(double currentTime) async {
    if(currentTime <0) {
      currentTime = 0.0;
    }
    if(_isPlaying == false) {
      _pauseAt = currentTime;
    } else {
      await play(currentTime: currentTime);
    }
    return this;
  }

  Future<AudioPlayer> play({double currentTime=null}) async {
    if(!_isPrepared) {
      await prepare();
    }
    await pause();
    if(currentTime == null) {
    } else {
      _pauseAt = currentTime;
    }
    _sourceNode = _context.createBufferSource();
    _gain = _context.createGain();
    _sourceNode.connectNode(_gain);

    _gain.connectNode(_context.destination);
    _sourceNode.buffer = _buffer;
    _gain.gain.value = _volume;
    _sourceNode.connectNode(_context.destination);
    _sourceNode.start(0, _pauseAt);
    print("#start ${_pauseAt.toInt()}");

    _isPlaying = true;
    _startAt = _context.currentTime - _pauseAt ;
  }

  Future<AudioPlayer> pause() async {
    if(!_isPrepared) {
      await prepare();
    }

    if (_sourceNode != null) {
      if(_isPlaying == true) {
        _pauseAt = _context.currentTime - _startAt;
      }
      _sourceNode.stop(0);
      _isPlaying = false;
    }
    return this;
  }

  FutureOr<AudioPlayer> stop() async {
    if(_isPlaying) {
      await pause();
    }
    _isPrepared = false;
    _isPlaying = false;
    if(_context != null) {
      _context.close();
    }
    return this;
  }




  Future<double> getVolume() async => _volume;

  void setVolume(double v) {
    if(v < 0.0) {
      v = 0.0;
    }
    _volume = v;
    _gain.gain.value = v;
  }
}