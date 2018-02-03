library umiuni2d_media_html5;

import 'dart:async';
import 'dart:html';
import 'dart:web_audio';
import 'package:umiuni2d_media/umiuni2d_media.dart' as umi;

class MediaManager extends umi.MediaManager {

  @override
  String assetsRoot;
  bool _useFileSystem;

  MediaManager(this.assetsRoot,{bool useFileSystem:false}) {
    _useFileSystem = true;
  }

  Map<String, AudioPlayer> _audioMap = {};

  Future<String> getAssetPath(String key) async {
    String p = assetsRoot.replaceAll(new RegExp(r"/$"), "");
    String k = (key).replaceAll(new RegExp(r"^/"), "");
    return p + "/" + k;
  }

  @override
  Future<MediaManager> setupMedia(String path) async {
    await MediaManager.loadFromUrl(await getAssetPath(path));
    return this;
  }

  @override
  Future<AudioPlayer> loadAudioPlayer(String playerId, String path) async {
    AudioPlayer player = await createAudio(playerId, path);
    await player.prepare();
    return player;
  }

  @override
  Future<AudioPlayer> createAudio(String playerId, String path) async {
    AudioPlayer player = new AudioPlayer(playerId, await getAssetPath(path));
    _audioMap[playerId] = player;
    return player;
  }

  @override
  AudioPlayer getAudioPlayer(String id) {
    return _audioMap[id];
  }

  static Future<HttpRequest> loadFromUrl(String url) async {
    Completer<HttpRequest> c = new Completer();
    HttpRequest request = new HttpRequest();
    request.responseType = "arraybuffer";
    request.onLoad.listen((ProgressEvent e) async {
      try {
        c.complete(request);
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
}

class AudioPlayer extends umi.AudioPlayer {
  AudioContext _context;
  AudioBuffer _buffer;
  AudioBufferSourceNode _sourceNode;
  GainNode _gain;

  String _playerId;
  String _url;

  @override
  String get plyerId => _playerId;

  @override
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

  @override
  Future<AudioPlayer> prepare() async {
    _pauseAt = 0.0;
    _startAt = 0.0;

    Completer<AudioPlayer> c = new Completer();
    HttpRequest request = new HttpRequest();
    request.responseType = "arraybuffer";
    request.onLoad.listen((ProgressEvent e) async {
      try {
        _context = new AudioContext();
        _gain = _context.createGain();
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


  @override
  Future<double> getCurrentTime() async {
    double t = 0.0;
    if(_isPlaying) {
      t = _context.currentTime - _startAt;
    } else {
      t = _pauseAt;
    }
    return t;
  }

  @override
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

  @override
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
    _sourceNode.connectNode(_gain);
    _gain.connectNode(_context.destination);
    _sourceNode.buffer = _buffer;
    setVolume(_volume);
    _sourceNode.connectNode(_context.destination);
    _sourceNode.start(0, _pauseAt);
    print("#start ${_pauseAt.toInt()}");

    _isPlaying = true;
    _startAt = _context.currentTime - _pauseAt ;
    return this;
  }

  @override
  Future<AudioPlayer> pause() async {
    if(!_isPrepared) {
      await prepare();
    }

    if (_sourceNode != null) {
      if(_isPlaying == true) {
        _pauseAt = _context.currentTime - _startAt;
        _sourceNode.stop(0);
      }
      _isPlaying = false;
    }
    return this;
  }

  @override
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

  @override
  Future<double> getVolume() async => _volume;

  @override
  void setVolume(double v) {
    if(v < 0.0) {
       v = 0.0;
    }
    _volume = v;
    _gain.gain.value = v*2-1.0;
  }
}
