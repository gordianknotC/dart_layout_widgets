

class AudioModel{
	final String url;
	final double length;
	final String title;
	AudioModel({this.url, this.length, this.title});
}

class AudioResourcesForWeb{
	static int calc(int minute, int second) => minute * 60 + second;
	static AudioModel electronicalA = AudioModel(
			url: '/assets/audio/myMusic_electronicalA.mp3', //fixme: change to A
			title: 'electronical music work - New Age collections A',
			length: 478.952836
	);
	static AudioModel electronicalB = AudioModel(
			url: '/assets/audio/myMusic_electronicalB.mp3', //'http://sites.google.com/site/yandusite/images/images/myMusic_electronicalB.mp3',
			title: 'electronical music work - techno collections A',
			length: 478.952836
	);
	static AudioModel gameTrack = AudioModel(
			url: '/assets/audio/myMusic_electronicalC.mp3', //'http://sites.google.com/site/yandusite/images/images/myMusic_electronicalC.mp3',
			title: 'electronical music work - gameTrack',
			length: 478.952836
	);
	
	static AudioModel school = AudioModel(
			url: '/assets/audio/myMusic_highschollWork.mp3', //'http://sites.google.com/site/yandusite/images/images/myMusic_highschollWork.mp3',
			title: 'electronical music work - high school work',
			length: 478.952836
	);
}


class AudioResources{
	static int calc(int minute, int second) => minute * 60 + second;
	static AudioModel electronicalA = AudioModel(
			url: 'assets/audio/myMusic_electronicalA.mp3', //fixme: change to A
			title: 'electronical music work - New Age collections A',
			length: 478.952836
	);
	static AudioModel electronicalB = AudioModel(
			url: 'assets/audio/myMusic_electronicalB.mp3', //'http://sites.google.com/site/yandusite/images/images/myMusic_electronicalB.mp3',
			title: 'electronical music work - techno collections A',
			length: 478.952836
	);
	static AudioModel gameTrack = AudioModel(
			url: 'assets/audio/myMusic_electronicalC.mp3', //'http://sites.google.com/site/yandusite/images/images/myMusic_electronicalC.mp3',
			title: 'electronical music work - gameTrack',
			length: 478.952836
	);
	
	static AudioModel school = AudioModel(
			url: 'assets/audio/myMusic_highschollWork.mp3', //'http://sites.google.com/site/yandusite/images/images/myMusic_highschollWork.mp3',
			title: 'electronical music work - high school work',
			length: 478.952836
	);
}

