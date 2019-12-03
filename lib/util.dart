
enum EBuildMode{
	profile, debug, release
}

EBuildMode get buildMode {
	if (const bool.fromEnvironment('dart.vm.product')) {
		return EBuildMode.release;
	}
	var result = EBuildMode.profile;
	assert(() {
		result = EBuildMode.debug;
		return true;
	}());
	return result;
}