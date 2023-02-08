import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

enum EPlatform{
	windows, ios, android, mac, fushia, linux
}

EPlatform getPlatform(){
	if (Platform == null) {
	  return EPlatform.windows;
	}
	try{
		if (Platform.isWindows) {
			return EPlatform.windows;
		} else if (Platform.isAndroid) {
			return EPlatform.android;
		} else if (Platform.isFuchsia) {
			return EPlatform.fushia;
		} else if (Platform.isIOS) {
			return EPlatform.ios;
		} else if (Platform.isMacOS) {
			return EPlatform.ios;
		} else if (Platform.isLinux) {
			return EPlatform.linux;
		}
		throw Exception('uncaught platform');
	} on UnsupportedError {
		return EPlatform.windows;
	} catch(e, s){
		return EPlatform.windows;
	}
}

final PLATFORM = getPlatform(); // ignore: non_constant_identifier_names
final IS_MOBILE = [EPlatform.android, EPlatform.fushia, EPlatform.ios].contains(PLATFORM); // ignore: non_constant_identifier_names


mixin StatefulMixin<T extends StatefulWidget> on State<T>{
	bool 			get isMobile  => IS_MOBILE;
	EPlatform get platform  => PLATFORM;
	void setStateSafe(void cb()){
		if (mounted){
			setState(cb);
		}else{
			print('[Errror] setState called after dispose: ${runtimeType}>${this.widget.key}');
		}
	}
	
	void scheduleUpdate(void cb()){
		SchedulerBinding.instance.addPostFrameCallback((d){
			setStateSafe(cb);
		});
	}
	void scheduleUpdateWhen(bool condition(), void cb()){
		if (condition()) {
		  scheduleUpdate(cb);
		}
	}
}