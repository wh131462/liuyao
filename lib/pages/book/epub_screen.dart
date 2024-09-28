import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';


class EPUBScreen extends StatefulWidget {
  final String? path;
  final String? name;

  EPUBScreen({Key? key, this.path, this.name}) : super(key: key);

  _EPUBScreenState createState() => _EPUBScreenState();
}

class _EPUBScreenState extends State<EPUBScreen> with WidgetsBindingObserver {
  final epubController = EpubController();

  var textSelectionCfi = '';

  bool isLoading = true;

  double progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ChapterDrawer(
        controller: epubController,
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.name??"文档"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchPage(
                        epubController: epubController,
                      )));
            },
          ),
        ],
      ),
      body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
              ),
              Expanded(
                child: Stack(
                  children: [
                    if(widget.path!.isNotEmpty)
                    EpubViewer(
                      epubSource: EpubSource.fromAsset(widget.path!),
                      epubController: epubController,
                      displaySettings: EpubDisplaySettings(
                          flow: EpubFlow.paginated,
                          snap: true,
                          allowScriptedContent: true),
                      selectionContextMenu: ContextMenu(
                        menuItems: [
                          ContextMenuItem(
                            title: "Highlight",
                            id: 1,
                            action: () async {
                              epubController.addHighlight(cfi: textSelectionCfi);
                            },
                          ),
                        ],
                        settings: ContextMenuSettings(
                            hideDefaultSystemContextMenuItems: true),
                      ),
                      onChaptersLoaded: (chapters) {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      onEpubLoaded: () async {
                        print('Epub loaded');
                      },
                      onRelocated: (value) {
                        print("Reloacted to $value");
                        setState(() {
                          progress = value.progress;
                        });
                      },
                      onAnnotationClicked: (cfi) {
                        print("Annotation clicked $cfi");
                      },
                      onTextSelected: (epubTextSelection) {
                        textSelectionCfi = epubTextSelection.selectionCfi;
                        print(textSelectionCfi);
                      },
                    ),
                    Visibility(
                      visible: isLoading,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}


class ChapterDrawer extends StatefulWidget {
  const ChapterDrawer({super.key, required this.controller});

  final EpubController controller;

  @override
  State<ChapterDrawer> createState() => _ChapterDrawerState();
}

class _ChapterDrawerState extends State<ChapterDrawer> {
  late List<EpubChapter> chapters;

  @override
  void initState() {
    chapters = widget.controller.getChapters();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(chapters[index].title),
                onTap: () {
                  widget.controller.display(cfi: chapters[index].href);
                  Navigator.pop(context);
                },
              );
            }));
  }
}


class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.epubController});

  final EpubController epubController;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var query = '';

  var searchResult = <EpubSearchResult>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search',
                ),
                onChanged: (value) async {},
                onSubmitted: (value) {
                  setState(() {
                    query = value;
                  });

                  widget.epubController.search(query: value).then((value) {
                    setState(() {
                      searchResult = value;
                    });
                  });
                },
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: searchResult.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            widget.epubController
                                .display(cfi: searchResult[index].cfi);
                            Navigator.pop(context);
                          },
                          title: HighlightText(
                              text: searchResult[index].excerpt,
                              highlight: query,
                              style: const TextStyle(),
                              highlightStyle: const TextStyle(
                                backgroundColor: Colors.yellow,
                              )),
                        );
                      }))
            ],
          ),
        ),
      ),
    );
  }
}

class HighlightText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle style;
  final TextStyle highlightStyle;
  final bool ignoreCase;

  const HighlightText({
    super.key,
    required this.text,
    required this.highlight,
    required this.style,
    required this.highlightStyle,
    this.ignoreCase = true,
  });

  @override
  Widget build(BuildContext context) {
    final text = this.text;
    if ((highlight.isEmpty) || text.isEmpty) {
      return Text(text, style: style);
    }

    var sourceText = ignoreCase ? text.toLowerCase() : text;
    var targetHighlight = ignoreCase ? highlight.toLowerCase() : highlight;

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;
    do {
      indexOfHighlight = sourceText.indexOf(targetHighlight, start);
      if (indexOfHighlight < 0) {
        // no highlight
        spans.add(_normalSpan(text.substring(start)));
        break;
      }
      if (indexOfHighlight > start) {
        // normal text before highlight
        spans.add(_normalSpan(text.substring(start, indexOfHighlight)));
      }
      start = indexOfHighlight + highlight.length;
      spans.add(_highlightSpan(text.substring(indexOfHighlight, start)));
    } while (true);

    return Text.rich(TextSpan(children: spans));
  }

  TextSpan _highlightSpan(String content) {
    return TextSpan(text: content, style: highlightStyle);
  }

  TextSpan _normalSpan(String content) {
    return TextSpan(text: content, style: style);
  }
}