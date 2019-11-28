import 'package:audioplayer/audioplayer.dart';
import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:behaviors/behaviors.dart';
import 'package:layout/models/audio_loader.dart';
import 'package:layout/models/audio_model.dart';
import 'package:layout/widgets/icons/spiningIcon.dart';
import 'package:layout/widgets/stateful.dart';


final _D = Logger(name:'AuWID', levels: LEVEL0);


enum EBtState{
	loading, playing, stopped, paused,
}


class SimpleAudioProgress extends StatelessWidget {
	final double width;
	final double height;
	final EdgeInsets padding;
	final SingleProgressAware awareness;
	final Color bgColor;
	final Color progressColor;
	const SimpleAudioProgress(this.awareness, {
		@required this.width, this.padding, this.height, Key key,
		this.bgColor, this.progressColor,
	}) : super(key: key);

  @override
  Widget build(BuildContext context) {
		return Observer(
				builder: observerGuard(() { //OB:
					final property_progress = awareness.property_progress;
					_D.debug('progress: $property_progress - ${width * property_progress}');
					return Container(
							height: height,
							width: width, // set constraint with
							color: bgColor,
							alignment: AlignmentDirectional.center,
							child: Container(
									height: height,
									width: width * property_progress,
									color: progressColor
							)
					);
				}, "SimpleAudioProgress.build"));
	
	}
}



// ignore: must_be_immutable
class SimpleAudioButton extends StatefulWidget implements SingleGroupAwareWidgetSketch<AudioModel>{
	final AudioModel model;
	final double height;
	final double width;
	final void Function(AudioModel) onPress;
	final AudioLoader audioLoader;
	
	final IconData spinIcon;
	final IconData playIcon;
	final IconData pauseIcon;
	final IconData stopIcon;
	
	final Color activeIconColor;
	final Color inactiveIconColor;
	
	final TextStyle literalStyle;
	final TextStyle boldStyle;
	final TextStyle accentStyle;
	
	final Color progressBgColor;
	final Color inProgressColor;
	
	
	@override SingleGroupAware<AudioModel> Function() awareness;
	
	SimpleAudioButton(this.model, {
		@required this.width, this.height = 32, this.onPress,
		this.awareness, this.spinIcon,  this.playIcon,
		this.stopIcon, this.pauseIcon,
		this.boldStyle, this.literalStyle, this.accentStyle,
		this.activeIconColor, this.inactiveIconColor,
		this.progressBgColor, this.inProgressColor, Key key,
	}):audioLoader = AudioLoader(model) ,super(key: key);
	
	@override State<StatefulWidget> createState() => SimpleAudioButtonState();
  @override void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SimpleAudioButtonState extends State<SimpleAudioButton> with StatefulMixin {
	AudioPlayerState get buttonState  => widget.audioLoader.state;
	SimpleAudioProgress progress;
	Size contextSize;
	
	void addAllListeners(){
		widget.audioLoader.onLoad((){
			_D.debug('onLoad: ${widget.model.url}, $buttonState');
			setStateSafe((){});
		});
		widget.audioLoader.onStopped((){
			_D.debug('onStopped: ${widget.model.url}');
			setStateSafe((){});
		});
		widget.audioLoader.onCompleted((){
			_D.debug('onCOmpleted: ${widget.model.url}');
			setStateSafe((){});
		});
		widget.audioLoader.onUpdate((d){
			progressAware.current = d.inSeconds.toDouble();
			//_D.debug('onupdate: $d');
		});
		widget.audioLoader.onPaused((){
			_D.debug('onPause: ${widget.model.url}');
			setStateSafe((){});
		});
		widget.audioLoader.onPlaying((){
			_D.debug('onPlay: ${widget.model.url}');
			setStateSafe((){});
		});
	}
	
	SingleProgressAware<double> progressAware;

	@override
  void initState() {
    super.initState();
    _D.debug('initState on audioButton');
		progressAware ??= SingleProgressAware(total: widget.model.length, current: 0);
		widget.audioLoader.initAudio();
		addAllListeners();
	}
 
	void _stop(){
		_D.debug('stop');
		widget.audioLoader.stop();
	}
	void _play(){
		_D.debug('play');
		widget.audioLoader.play();
	}
	void _pause(){
		_D.debug('pause');
		widget.audioLoader.pause();
	}
	void onPress(){
		if (buttonState == null){
			_D.debug('block play back, since it"s still loading');
			return;
		}
		if (widget.audioLoader.isPlaying) {
		  _pause();
		}else{
			_play();
		}
		widget.onPress?.call(widget.model);
	}
	Widget _buildButton(IconData icon, [bool spining = false]){
		final title = widget.model.title.split('-');
		final label = Text.rich(
			TextSpan(children:[
				TextSpan(text: title[0],        style: widget.literalStyle),
				TextSpan(text: "\n${title[1]}", style: widget.awareness().isActivated(widget.model) ? widget.accentStyle : widget.boldStyle)
			])
		);
		double length = widget.model.length;
		///
		/// fetch context size on post frame...
		SchedulerBinding.instance.addPostFrameCallback((_) {
			contextSize = context?.size;
			_D.info('update contextSize: $contextSize');
		});
		
		final double w = contextSize == null
				? 0
				: contextSize.width;
		
		final mainButton = Tooltip(
			message: widget.model.title,
			child: MaterialButton(
				onPressed: onPress,
				elevation: 2,
				child:  FlatButton.icon(
					onPressed: null,
					icon: spining
							? SpiningIcon(icon, color: widget.awareness().isActivated(widget.model) ? widget.activeIconColor : widget.inactiveIconColor, size: 24)
							: Icon(icon,        color: widget.awareness().isActivated(widget.model) ? widget.activeIconColor : widget.inactiveIconColor, size: 24),
					label: label,
				),
				//hoverColor: Colors.blueGrey[800],
			),
		);
		
		return  Column(
			key: ObjectKey(widget.audioLoader),
			crossAxisAlignment: CrossAxisAlignment.start,
			children: <Widget>[
				mainButton,
				if (contextSize != null)
					progress ??= SimpleAudioProgress(progressAware,
						bgColor			 : widget.progressBgColor,
						progressColor: widget.inProgressColor,
						width: w, height: 2)
			],
		);
	}
	
  Widget buildLoadingButton(){
		return _buildButton(widget.spinIcon, true);
	}
	Widget buildPlayingButton(){
		return _buildButton(widget.pauseIcon ?? Icons.pause);
	}
	Widget buildNormalButton(){
		return _buildButton(widget.playIcon ?? Icons.play_circle_outline);
	}
	Widget buildPausedButton(){
		return _buildButton(widget.stopIcon ?? Icons.stop);
	}
  Widget buildButton(){
		switch (buttonState) {
			case AudioPlayerState.PLAYING:
				return buildPlayingButton();
			case AudioPlayerState.COMPLETED:
			case AudioPlayerState.STOPPED:
				return buildNormalButton();
			case AudioPlayerState.PAUSED:
				return buildPausedButton();
			default:
				if (buttonState == null) {
				  return buildLoadingButton();
				}
				throw Exception('Uncaught Enum...');
		}
	}
	
	
	double property_progress = 0;
	@override Widget build(BuildContext context) {
		_D.debug('build simple audio button:${buttonState}');
		return buildButton();
	}
	
	@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.audioLoader.dispose();
  }
}

// ignore: must_be_immutable



