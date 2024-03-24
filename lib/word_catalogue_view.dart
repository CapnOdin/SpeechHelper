
import 'dart:convert';
import 'dart:io';

import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:speech_helper/app_screen.dart';
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
		Util.logD("Opening ${widget.model.isSubCatalogue ? 'subcatalogue' : "catalogue"} ${widget.model.name}");
		return LayoutBuilder(builder: (context, constraints) {
			return ScrollShadow(
				color: Colors.grey,
				child: GridView.builder(
					itemCount: widget.model.wordLst.length + widget.model.subCatalogues.length + (widget.model.isSubCatalogue ? 1 : 0),
					gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: constraints.maxWidth > 700 ? 4 : 2),
					itemBuilder: (_, int index) {
						// Adding the back button if this is a subcatalogue
						if(index == 0 && widget.model.isSubCatalogue) {
							return backButtonWidget();
						}
						// Adding any subcatalogues
						if(getIndex(index) < 0) {
							return subCatalogueWidget(widget.model.subCatalogues[index - (widget.model.isSubCatalogue ? 1 : 0)]);
						}
						// Adding all the words
						return wordWidget(widget.model.wordLst[getIndex(index)]);
					}
				)
			);
		});
	}

	int getIndex(int index) {
		return index - widget.model.subCatalogues.length - (widget.model.isSubCatalogue ? 1 : 0);
	}

	Widget backButtonWidget() {
		return tileWidget(
			children: [
				FittedBox(fit: BoxFit.contain, clipBehavior: Clip.hardEdge, child: Icon(Icons.circle, color: Colors.grey.withOpacity(0.50))),
				const FittedBox(fit: BoxFit.contain, clipBehavior: Clip.hardEdge, child: Icon(Icons.arrow_back)),
				Material(color: Colors.transparent,
					child: InkWell(
						onTap: () => Navigator.pop(context),
						onLongPress: () => Navigator.pop(context),
					),
				),
			]
		);
	}

	Widget subCatalogueWidget(WordCatalogueModel model) {
		return tileWidget(
			children: [
				FittedBox(fit: BoxFit.contain, clipBehavior: Clip.hardEdge, child: Icon(Icons.folder, color: Colors.grey.withOpacity(0.50))),
				FittedBox(fit: BoxFit.contain, clipBehavior: Clip.hardEdge, child: Text(model.name)),
				Material(color: Colors.transparent,
					child: InkWell(
						onTap: () => {
							Navigator.push(
								context,
								MaterialPageRoute(builder: (context) => 
									AppScreen(
										floatingActionButton: quickMenu(context, model),
										body: Padding(padding: const EdgeInsets.all(8.0),
											child: WordCatalogue(
												key: model.key,
												model: model,
												onChoice: null,
											)
										),
										title: Text(model.name),
									)
								),
							).then((value) => setState(() {},))
						},
						onLongPress: () => Navigator.pop(context),
					),
				),
			]
		);
	}

	Widget wordWidget(WordModel model) {
		return tileWidget(
			children: [
				if(model.icon != null) ...[
					FittedBox(fit: BoxFit.contain, clipBehavior: Clip.hardEdge, child: Icon(model.icon)),
				 ] else ...[
					FittedBox(fit: BoxFit.contain, clipBehavior: Clip.hardEdge, child: Text(model.word)),
				],
				Material(color: Colors.transparent,
					child: InkWell(
						onTap: () => _toggle(model),
						onLongPress: () => _toggle(model),
						//onLongPress: () => _wordSelected(context, index),
					),
				),
			]
		);
	}

	Widget tileWidget({List<Widget> children = const <Widget>[], Color? color}) {
		return GridTile(
			child: Center(
				child: Container(
					margin: const EdgeInsets.only(left:5, top:5, right:5, bottom:5),
					color: color,
					child: Stack(
						fit: StackFit.expand,
						children: children,
					),
				)
			)
		);
	}

	Future<void> addWordDialog(BuildContext context, WordCatalogueModel model) {
		GlobalKey<EditableTextState> wordKey = GlobalKey(debugLabel: "wordKey");
		final myController = TextEditingController();
		return showDialog<void>(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: const Text('Add a Word'),
					content: TextField(key: wordKey, controller: myController, autofocus: true),
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
							),
							child: const Text('Add', textAlign: TextAlign.end),
							onPressed: () {
								Navigator.of(context).pop();
								Util.logD("Adding Word to ${model.isSubCatalogue ? 'subcatalogue' : "catalogue"} ${model.name}");
								model.key.currentState?.addNewWord(myController.text);
							},
						),
					],
				);
			},
		);
	}

	Widget quickMenu(BuildContext context, WordCatalogueModel model) {
		return SpeedDial(
			icon: Icons.more_horiz,
			closeManually: true,
			renderOverlay: false,
			children: [
				SpeedDialChild(
					child: const Icon(Icons.add),
					label: "Add Word",
					onTap: () => model.key.currentState?.addWordDialog(context, model),
				),
				SpeedDialChild(
					child: const Icon(Icons.do_not_disturb),
					label: "Nej",
					onTap: () => model.key.currentState?.tts("Nej"),
				),
				SpeedDialChild(
					child: const Icon(Icons.check),
					label: "Ja",
					onTap: () => model.key.currentState?.tts("Ja"),
				),
			],
		);
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
			tts(model.pronunciation ?? model.word);
		}
	}

	Future<void> tts(String word) async {
		await flutterTts.speak(word);
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
			await flutterTts.setSpeechRate(0.5);
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
	final String name;
	final List<WordModel> wordLst;
	final List<WordCatalogueModel> subCatalogues;
	final bool isSubCatalogue;

	late GlobalKey<WordCatalogueState> key;

	String _appDocPath = "";

	WordCatalogueModel({required this.name, required this.wordLst, required this.subCatalogues, required Function() callback, this.isSubCatalogue = false}) {
		key = GlobalKey(debugLabel: "${name}Key");
		_setAppDocPath(callback);
	}

	Future<void> _setAppDocPath(Function() callback) async {
		_appDocPath = Util.handleWinPath("${(await getApplicationDocumentsDirectory()).path}/Words");
		Directory dir = Directory(_appDocPath);
		dir.create();
		await _loadJson(callback);
	}

	Future<void> _loadJson(Function() callback) async {
		File f = File("$_appDocPath/${name}_words.json");
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
				Util.log("Words Found: ${f.path}");
			} else {
				Util.log("Words Not Found: ${f.path}");
			}
		});
	}

	void _saveJson() async {
		Util.logD(Util.handleWinPath("$_appDocPath/${name}_words.json"));
		File(Util.handleWinPath("$_appDocPath/${name}_words.json")).openWrite().write(toJson());
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
