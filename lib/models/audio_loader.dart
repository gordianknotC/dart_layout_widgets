import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:common/common.dart';
import 'package:flutter/services.dart';
import 'package:layout/models/audio_model.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path/path.dart' as _path;
import 'package:path_provider/path_provider.dart';


final _D = Logger(name:'AuLoad', levels: LEVEL0);

class _AudioCache{
	final String filepath;
	final String folder;
	final String filename;
	String cacheString;
	_AudioCache(this.filepath): folder = _path.dirname(filepath), filename = _path.basename(filepath);
	
	Future init() async {
		if (cacheString != null) {
		  return;
		}
		final ByteData data = await rootBundle.load(filepath);
		Directory tempDir = await getTemporaryDirectory();
		File tempFile = File(_path.join(tempDir.path, filename));
		await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
		cacheString = tempFile.uri.toString();
	}
}

class _SingleAudioLocalPlayer {
	static final Map<String, _SingleAudioLocalPlayer> _allplayers = {};
	static final AudioPlayer _player = AudioPlayer();
	final String filepath;
	final _AudioCache cache;
	bool activated = false;
	
	_SingleAudioLocalPlayer._(this.filepath, this.cache);
	
	factory _SingleAudioLocalPlayer(String filepath, _AudioCache cache){
		if (_allplayers.containsKey(filepath)) {
		  return _allplayers[filepath];
		}
		final result = _SingleAudioLocalPlayer._(filepath, cache);
		return _allplayers[filepath] = result;
	}
	
	Future<bool> initAudio() async {
		if (cache.cacheString == null){
			await cache.init();
			_onLoadController.add(true);
			return true;
		}
		return false;
	}
	
	AudioPlayerState get state {
		if (cache.cacheString == null) {
		  return null;
		}
		if (activated) {
		  return _player.state;
		}
		return AudioPlayerState.STOPPED;
	}
	
	Stream<AudioPlayerState> get onPlayerStateChanged {
		return _player.onPlayerStateChanged.where((d){
			if (d == AudioPlayerState.STOPPED) {
			  return true;
			}
			return activated;
		});
	}
	Stream<Duration> 				 get onAudioPositionChanged {
		return _player.onAudioPositionChanged.where((d){
			return activated;
		});
	}
	
	Future play(){
		_allplayers.forEach((k, v){
			if (v.activated && v.filepath != filepath){
				_D('stop activated player: ${v.filepath}');
				v.stop();
			}
		});
		activated = true;
		return cache.init().then((_){
			_D('play $filepath');
			return _player.play(cache.cacheString, isLocal: true);
		});
	}
	
	Future pause(){
		return _player.pause();
	}
	
	Future stop(){
		activated = false;
		return _player.stop();
	}
	
	final StreamController<bool> _onLoadController = StreamController<bool>.broadcast();
	StreamSubscription<bool> _onLoadSubscription;
	void Function() _onLoad;
	void onLoad(void onData()) {
		_onLoad = onData;
		_onLoadSubscription = _onLoadController.stream.listen((_){
			_onLoad();
		});
	}
	
	void dispose(){
		_onLoadSubscription?.cancel();
	}
}


class AudioLoader{
	final _SingleAudioLocalPlayer player;
	final AudioModel model;
	
	bool get isLoaded 	=>  player?.cache?.cacheString != null;
	bool get isPaused 	=>  player?.state == AudioPlayerState.PAUSED;
	bool get isPlaying 	=>  player?.state == AudioPlayerState.PLAYING;
	bool get isCompleted=>  player?.state == AudioPlayerState.COMPLETED;
	bool get isStopped 	=>  player?.state == AudioPlayerState.STOPPED;
	AudioPlayerState get state {
		return player?.state;
	}
	
	AudioLoader(this.model): player = _SingleAudioLocalPlayer(model.url, _AudioCache(model.url));
	
	Future<bool> initAudio() async {
		return player.initAudio();
	}
	
	Future playFromStart(){
		player.stop();
		return player.play();
	}
	
	Future play(){
		return player.play();
	}
	
	void pause(){
		if (player != null){
			_D('pause ${model.url}');
			player.pause();
		}
	}
	void playOrPause(){
		if (player != null){
			if (player.state == AudioPlayerState.PLAYING) {
			  pause();
			} else {
			  play();
			}
		}else{
			play();
		}
	}
	void stop(){
		if (player != null){
			player.stop();
		}
	}
	
	StreamSubscription<AudioPlayerState> _onPlayerStateSubscription;
	void _playerStateMonitorInit(){
		if (_onPlayerStateSubscription == null){
			_onPlayerStateSubscription ??= player.onPlayerStateChanged.listen((state){
				switch(state){
					case AudioPlayerState.STOPPED:
						_D('stopeed ${model.url}');
						_onStopped?.call();
						break;
					case AudioPlayerState.PLAYING:
						_D('playing ${model.url}');
						_onPlaying?.call();
						break;
					case AudioPlayerState.PAUSED:
						_D('paused ${model.url}');
						_onPaused?.call();
						break;
					case AudioPlayerState.COMPLETED:
						_D('completed ${model.url}');
						_onCompleted?.call();
						break;
				}
			});
			_D.info('_playerStateMonitorInit: $_onPlayerStateSubscription');
		}
	}
	
	void Function() _onPlaying;
	void onPlaying(void onData()) {
		_playerStateMonitorInit();
		_onPlaying = onData;
	}
	
	void Function() _onStopped;
	void onStopped(void onData()) {
		_playerStateMonitorInit();
		_onStopped = onData;
	}
	
	void Function() _onPaused;
	void onPaused(void onData()) {
		_playerStateMonitorInit();
		_onPaused = onData;
	}
	
	void Function() _onCompleted;
	void onCompleted(void onData()) {
		_playerStateMonitorInit();
		_onCompleted = onData;
	}
	
	void onLoad(void onData()) {
		player.onLoad(onData);
	}
	
	StreamSubscription<Duration> onUpdateSubscription;
	void Function(Duration e) _onUpdate;
	void onUpdate(void onData(Duration e), {bool cancelOthers = true}) {
		_D.info('onUpdate init');
		if (cancelOthers) onUpdateSubscription?.cancel?.call();
		_onUpdate = onData;
		onUpdateSubscription = player.onAudioPositionChanged
			.where((e) => player.activated)
			.listen(_onUpdate);
	}
	
	void dispose(){
		_D.info('dispose audio player...');
		_onPlayerStateSubscription?.cancel();
		onUpdateSubscription?.cancel();
		player._onLoadSubscription?.cancel();
	}
}





