
import 'package:flutter/material.dart';
import 'package:speech_helper/app_screen.dart';
import 'package:speech_helper/word_catalogue_view.dart';

void main() {
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	// This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Speech Helper',
			theme: ThemeData(
				// This is the theme of your application.
				//
				// TRY THIS: Try running your application with "flutter run". You'll see
				// the application has a purple toolbar. Then, without quitting the app,
				// try changing the seedColor in the colorScheme below to Colors.green
				// and then invoke "hot reload" (save your changes or press the "hot
				// reload" button in a Flutter-supported IDE, or press "r" if you used
				// the command line to start the app).
				//
				// Notice that the counter didn't reset back to zero; the application
				// state is not lost during the reload. To reset the state, use hot
				// restart instead.
				//
				// This works for code too, not just values: Most code changes can be
				// tested with just a hot reload.
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
				useMaterial3: true,
			),
			home: const MyHomePage(title: 'Speech Helper'),
		);
	}
}

class MyHomePage extends StatefulWidget {
	const MyHomePage({super.key, required this.title});

	// This widget is the home page of your application. It is stateful, meaning
	// that it has a State object (defined below) that contains fields that affect
	// how it looks.

	// This class is the configuration for the state. It holds the values (in this
	// case the title) provided by the parent (in this case the App widget) and
	// used by the build method of the State. Fields in a Widget subclass are
	// always marked "final".

	final String title;

	@override
	State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	GlobalKey<WordCatalogueState> wordCatalogueKey = GlobalKey(debugLabel: "wordCatalogueKey");
	WordCatalogueModel? wordCatalogueModel;

	Future<void> _buttonClicked(BuildContext context) {
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
								wordCatalogueKey.currentState!.addNewWord(myController.text);
							},
						),
					],
				);
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		wordCatalogueModel ??= WordCatalogueModel(
			name: "Catalogue",
			wordLst: [],
			subCatalogues: [
				WordCatalogueModel(
					name: "Hilsner",
					wordLst: [	WordModel(word: "Hej"),
								WordModel(word: "Farvel"),
								WordModel(word: "Goddag"),
								WordModel(word: "Vi Ses"),
								WordModel(word: "Hej Halv Øje"),
								WordModel(word: "Vi ses, hvis vi ikke er blevet blinde"),
					],
					subCatalogues: [],
					callback: () => setState(() {}),
					isSubCatalogue: true
				),
				WordCatalogueModel(
					name: "Behov",
					wordLst: [	WordModel(word: "Hjælp"),
								WordModel(word: "Gør Ondt"),
								WordModel(word: "Sulten"),
								WordModel(word: "Tørstig"),
								WordModel(word: "På Toilettet"),
								WordModel(word: "Tisse"),
								WordModel(word: "Lort"),
								WordModel(word: "Træt"),
								WordModel(word: "TV"),
								WordModel(word: "Fred"),
								WordModel(word: "Selvskab"),
					],
					subCatalogues: [],
					callback: () => setState(() {}),
					isSubCatalogue: true
				),
				WordCatalogueModel(
					name: "Svar",
					wordLst: [	WordModel(word: "Ja"),
								WordModel(word: "Nej"),
								WordModel(word: "Måske"),
								WordModel(word: "Ved Ikke"),
					],
					subCatalogues: [],
					callback: () => setState(() {}),
					isSubCatalogue: true
				),
				WordCatalogueModel(
					name: "Spørge",
					wordLst: [	WordModel(word: "Hvad"),
								WordModel(word: "Hvem"),
								WordModel(word: "Hvor"),
								WordModel(word: "Hvordan"),
								WordModel(word: "Hvorfor"),
								WordModel(word: "Hvornår"),
					],
					subCatalogues: [],
					callback: () => setState(() {}),
					isSubCatalogue: true
				),
				WordCatalogueModel(
					name: "Personer",
					wordLst: [	WordModel(word: "Jeg"),
								WordModel(word: "Du"),
								WordModel(word: "Vi"),
								WordModel(word: "Jer"),
								WordModel(word: "I"),
								WordModel(word: "Mig"),
								WordModel(word: "Anne"),
								WordModel(word: "Augusta"),
								WordModel(word: "Albert"),
								WordModel(word: "Anton"),
					],
					subCatalogues: [],
					callback: () => setState(() {}),
					isSubCatalogue: true
				),
				WordCatalogueModel(
					name: "Steder",
					wordLst: [	WordModel(word: "Toilet"),
								WordModel(word: "Stue"),
								WordModel(word: "Lejlighed"),
								WordModel(word: "Skov"),
								WordModel(word: "Sø"),
					],
					subCatalogues: [],
					callback: () => setState(() {}),
					isSubCatalogue: true
				),
				WordCatalogueModel(
					name: "Følelser",
					wordLst: [	WordModel(word: "Glad"),
								WordModel(word: "Trist"),
								WordModel(word: "Ked af det"),
								WordModel(word: "Sur"),
								WordModel(word: "Forvirret"),
					],
					subCatalogues: [],
					callback: () => setState(() {}),
					isSubCatalogue: true
				),
				WordCatalogueModel(
					name: "Krop",
					wordLst: [	WordModel(word: "Hovet"),
								WordModel(word: "Skulder"),
								WordModel(word: "Arm"),
								WordModel(word: "Brystkasse"),
								WordModel(word: "Mave"),
								WordModel(word: "Skridt"),
								WordModel(word: "Numse"),
								WordModel(word: "Lår"),
								WordModel(word: "Ben"),
								WordModel(word: "Fod"),
					],
					subCatalogues: [],
					callback: () => setState(() {}),
					isSubCatalogue: true
				),
				WordCatalogueModel(
					name: "Bindeord",
					wordLst: [	WordModel(word: "At"),
								WordModel(word: "Og"),
								WordModel(word: "Dengang"),
								WordModel(word: "Medmindre"),
					],
					subCatalogues: [],
					callback: () => setState(() {}),
					isSubCatalogue: true
				),
				WordCatalogueModel(
					name: "Forholdsord",
					wordLst: [	WordModel(word: "Højre"),
								WordModel(word: "Venstre"),
								WordModel(word: "Af"),
								WordModel(word: "Ifølge"),
								WordModel(word: "Over"),
								WordModel(word: "Mellem"),
								WordModel(word: "Under"),
					],
					subCatalogues: [],
					callback: () => setState(() {}),
					isSubCatalogue: true
				),
			],
			callback: () => setState(() {})
		);
		return AppScreen(title: const Text("Catalogue"),
			floatingActionButton: FloatingActionButton(
				onPressed: () => _buttonClicked(context),
				tooltip: "Add Word",
				child: const Icon(Icons.add),
			),
			body: Padding(padding: const EdgeInsets.all(8.0),
				child: WordCatalogue(
					key: wordCatalogueKey,
					model: wordCatalogueModel!,
					onChoice: null,
				)
			),
		);
	}
}
