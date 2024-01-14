
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart';

class Util {
	static logD(object) {
		if(kDebugMode) {
			print(object);
		}
	}

	static log(object) {
		//if(kDebugMode) {
			print(object);
		//}
	}

	static logW(object) {
		//if(kDebugMode) {
			print("Warn: $object");
		//}
	}

	static logE(object) {
		//if(kDebugMode) {
			print("Error: $object");
		//}
	}

	static Future<void> writeToFile(Uint8List data, String path) {
		return File(path).writeAsBytes(data);
	}

	static String handleWinPath(String path) {
		if(Platform.isWindows) {
			return toWinPath(path);
		}
		return path;
	}

	static String toWinPath(String path) {
		return path.replaceAll("/", Platform.pathSeparator);
	}

	static String escapePathJson(String path) {
		return path.replaceAll("\\", "\\\\");
	}

	static String unEscapePathJson(String path) {
		return path.replaceAll("\\\\", "\\");
	}
}
