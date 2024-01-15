
import 'dart:convert';
import 'dart:io';

import 'package:speech_helper/util.dart';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

class WordCatalogue extends StatefulWidget {
	final Function(String)? onChoice;
	final WordCatalogueModel model;

	const WordCatalogue({
		super.key,
		required this.model,
		required this.onChoice,
	});

	@override
	WordCatalogueState createState() {
		return WordCatalogueState();
	}
}

class WordCatalogueState extends State<WordCatalogue> {
	FlutterTts flutterTts = FlutterTts();

	@override
	Widget build(BuildContext context) {
		return _catalogue();
	}

	@override
	void initState() {
		initTTS();
		super.initState();
	}

	Widget _catalogue() {
		Util.logD("_catalogue");
		return LayoutBuilder(builder: (context, constraints) {
			return GridView.builder(
				itemCount: widget.model.wordLst.length,
				gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: constraints.maxWidth > 700 ? 4 : 2),
				itemBuilder: (_, int index) {
					return GridTile(
						child: Center(
							child: Container(
								margin: const EdgeInsets.only(left:5, top:5, right:5, bottom:5),
								child: Stack(
									fit: StackFit.expand,
									children: [
										wordWidgit(widget.model.wordLst[index]),
										Material(color: Colors.transparent,
											child: InkWell(
												onTap: () => _toggle(widget.model.wordLst[index]),
												onLongPress: () => _wordSelected(context, index),
											),
										),
									],
								)
							)
						)
					);
				}
			);
		});
	}

	void addNewWord(String word) {
		setState(() {
			widget.model.addWord(word);
		});
	}

	void removeWord(int index) {
		setState(() {
			widget.model.removeWord(index);
		});
	}

	void _toggle(WordModel model) {
		if(widget.onChoice != null) {
			widget.onChoice!.call(model.word);
		} else {
			_tts(model.pronunciation ?? model.word);
		}
	}

	Future<void> _tts(String word) async {
		await flutterTts.speak(word);
	}

	Widget wordWidgit(WordModel model) {
		if(model.icon != null) {
			return FittedBox(fit: BoxFit.contain, clipBehavior: Clip.hardEdge, child: Icon(model.icon));
		} else {
			return FittedBox(fit: BoxFit.contain, clipBehavior: Clip.hardEdge, child: Text(model.word));
		}
	}

	Future<void> initTTS() async {
		if(Platform.isIOS) {
			await flutterTts.setSharedInstance(true);
			await flutterTts.setIosAudioCategory(
				IosTextToSpeechAudioCategory.ambient,
				[
					IosTextToSpeechAudioCategoryOptions.allowBluetooth,
					IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
					IosTextToSpeechAudioCategoryOptions.mixWithOthers
				],
				IosTextToSpeechAudioMode.voicePrompt
			);
		}

		if(Platform.isAndroid) {
			await flutterTts.setSpeechRate(0.5);
		} else if(Platform.isIOS) {
			await flutterTts.setSpeechRate(1.0);
		}

		List<dynamic> languages = await flutterTts.getLanguages;
		Util.logD(languages);

		await flutterTts.setLanguage("da-DK");
		await flutterTts.setVolume(1.0);
		await flutterTts.setPitch(1.0);
	}

	Future<void> _wordSelected(BuildContext context, int index) {
		return showDialog<void>(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: const Text('Remove Word'),
					actions: <Widget>[
						TextButton(
							style: TextButton.styleFrom(
								textStyle: Theme.of(context).textTheme.labelLarge,
							),
							child: const Text('Cancel', textAlign: TextAlign.end),
							onPressed: () {
								Navigator.of(context).pop();
							},
						),
						TextButton(
							style: TextButton.styleFrom(
								textStyle: Theme.of(context).textTheme.labelLarge,
								foregroundColor: Colors.red,
							),
							child: const Text('Remove', textAlign: TextAlign.end),
							onPressed: () {
								Navigator.of(context).pop();
								removeWord(index);
							},
						),
					],
				);
			},
		);
	}
}

class WordCatalogueModel {
	final List<WordModel> wordLst;

	String _appDocPath = "";

	WordCatalogueModel({required this.wordLst, required Function() callback}) {
		_setAppDocPath(callback);
	}

	Future<void> _setAppDocPath(Function() callback) async {
		_appDocPath = Util.handleWinPath("${(await getApplicationDocumentsDirectory()).path}/Words");
		Directory dir = Directory(_appDocPath);
		dir.create();
		await _loadJson(callback);
	}

	Future<void> _loadJson(Function() callback) async {
		File f = File("$_appDocPath/words.json");
		f.exists().then((exists) {
			if(exists) {
				Map<String, dynamic> json = jsonDecode(f.readAsStringSync());
				List<dynamic> jsonWords = json["words"];
				for(var element in jsonWords) {
					WordModel word = WordModel.fromJson(element);
					if(!wordLst.contains(word)) {
						wordLst.add(word);
					}
				}
				callback.call();
				Util.log("Words Found: ${f.path}${Platform.pathSeparator}words.json");
			} else {
				Util.log("Words Not Found: ${f.path}");
			}
		});
	}

	void _saveJson() async {
		Util.logD(Util.handleWinPath("$_appDocPath/words.json"));
		File(Util.handleWinPath("$_appDocPath/words.json")).openWrite().write(toJson());
	}

	Map<String, dynamic> toJson() => {
		'"words"': wordLst.map((w) => w.toJson()).toList()
	};

	void addWord(String word) {
		wordLst.add(WordModel(word: word));
		_saveJson();
	}

	void removeWord(int index) {
		wordLst.removeAt(index);
		_saveJson();
	}
}

class WordModel {
	final String word;
	String? pronunciation;
	IconData? icon;

	WordModel({required this.word, this.pronunciation, this.icon});

	WordModel.fromJson(Map<String, dynamic> json) : word = json["word"], pronunciation = json["pronunciation"] {
		icon = json["icon"] != null ? _iconDataFromJSONString(json["icon"]) : null;
	}

	Map<String, dynamic> toJson() => {
		'"word"':               '"$word"',
		'"pronunciation"':      pronunciation != null ? '"$pronunciation"' : null,
		'"icon"':				icon != null ? _iconDataToJSONString(icon!) : null
	};

	@override
	bool operator ==(Object other) {
		if(identical(this, other)) {
			return true;
		}
		if(other.runtimeType != runtimeType) {
			return false;
		}
		return other is WordModel
			&& other.word == word
			&& other.pronunciation == pronunciation
			&& other.icon == icon;
	}

	@override
	int get hashCode => Object.hash(word, pronunciation, icon);

	String _iconDataToJSONString(IconData data) {
		Map<String, dynamic> map = <String, dynamic>{};
		map['codePoint'] = data.codePoint;
		map['fontFamily'] = data.fontFamily;
		map['fontPackage'] = data.fontPackage;
		map['matchTextDirection'] = data.matchTextDirection;
		return jsonEncode(map);
	}

	IconData _iconDataFromJSONString(String jsonString) {
		Map<String, dynamic> map = jsonDecode(jsonString);
		return IconData(
			map['codePoint'],
			fontFamily: map['fontFamily'],
			fontPackage: map['fontPackage'],
			matchTextDirection: map['matchTextDirection'],
		);
	}
}
