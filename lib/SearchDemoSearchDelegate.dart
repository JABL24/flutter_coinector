import 'package:Coinector/translator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SuggestionList.dart';
import 'Suggestions.dart';
import 'Tag.dart';
import 'UrlLauncher.dart';

class SearchDemoSearchDelegate extends SearchDelegate<String> {
  final Set<String> _historyBackup = Set.from(Suggestions.locations);
  final Set<String> _history = Set.from(Suggestions.locations);
  String hintText;

  SearchDemoSearchDelegate({String hintText = "Satoshi lives, children yeaha!"})
      : super(
          searchFieldStyle:
              TextStyle(inherit: false, color: Colors.black45, fontSize: 16),
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  buildHistory() async {
    List<String> historyItems = await getHistory();
    if (historyItems == null || historyItems.isEmpty) return;

    historyItems = _reverseList(historyItems);
    _history.clear();
    historyItems.forEach((item) => _history.add(item));
    _history.addAll(_historyBackup);
  }

  _reverseList(List<String> list) {
    List<String> reversedList = [];
    list.forEach((item) => reversedList.insert(0, item));
    return reversedList;
  }

  var _kNotificationsPrefs = "historyItems";

  Future<List<String>> getHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_kNotificationsPrefs);
  }

  Future<bool> setHistory(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_kNotificationsPrefs, value);
  }

  bool hasResults;

  _getSuggestions(String pattern, ctx) {
    Set<String> matches = Set.from([]);

    addCountrySpecificMatches(ctx, pattern, matches);

    addMatches(pattern, matches, Suggestions.locations);
    addMatches(pattern, matches, Tag.titleTags);

    hasResults = true;
    if (matches.length == 0) {
      matches.add(translate(ctx, "try_another_word"));
      //matches.add(TRY_ANOTHER_WORD);
      hasResults = false;
    }

    return matches;
  }

  String translate(ctx, text) {
    String t = Translator.translate(ctx, text);
    return t.isNotEmpty ? t : " ";
  }

  void addCountrySpecificMatches(ctx, String pattern, Set<String> matches) {
    switch (UrlLauncher.getLocale(ctx)) {
      case "de":
        addMatches(pattern, matches, Tag.tagTextDE);
        break;
      case "es":
        addMatches(pattern, matches, Tag.tagTextES);
        break;
      case "ja":
        addMatches(pattern, matches, Tag.tagTextJP1);
        addMatches(pattern, matches, Tag.tagTextJP2);
        break;
      case "fr":
        addMatches(pattern, matches, Tag.tagTextFR);
        break;
      case "id":
        addMatches(pattern, matches, Tag.tagTextINDONESIA);
        break;
      case "it":
        addMatches(pattern, matches, Tag.tagTextIT);
        break;
    }
    addMatches(pattern, matches, Tag.tagText);
  }

  void addMatches(String pattern, Set<String> matches, set) {
    for (int x = 0; x < set.length; x++) {
      addMatch(x, pattern, matches, set.elementAt(x));
    }
  }

  void addMatch(
      int x, String pattern, Set<String> matches, String currentItem) {
    if (startsWith(currentItem, pattern)) {
      matches.add(currentItem);
    }
  }

  bool startsWith(String currentItem, String pattern) =>
      currentItem.toLowerCase().startsWith(pattern.toLowerCase());

  //static const TRY_ANOTHER_WORD = 'Not found! Try another word!';

  _addHistoryItem(String item) async {
    List<String> historyItems = await getHistory();

    if (historyItems == null) historyItems = [];

    historyItems.add(item);
    _history.add(item);
    setHistory(historyItems);
    buildHistory();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Set<String> suggestions;

    if (query.isEmpty) {
      suggestions = Set.from([
        translate(context, "you_can_scroll"),
      ]);
      suggestions.addAll(_history);
    } else {
      suggestions = _getSuggestions(query, context);
    }

    return SuggestionList(
      query: query,
      suggestions: suggestions.map<String>((String i) => i).toList(),
      onSelected: (String match) {
        String title = match.split(Suggestions.separator)[0];
        query = title.split(" - ")[0];
        _addHistoryItem(match);
        close(context, match);
      },
    );
  }

  @override
  void showResults(BuildContext context) {
    //DONT SHOW ANY RESULTS HERE, SIMPLY REMOVE THE WIDGET
    //THIS METHOD IS CALLED AFTER USER HITS THE SEARCH ICON OF THE KEYBOARD LAYOUT
    //This app doesnt need this button as we autosearch on every keystroke
    String text;
    if (query.trim().isEmpty) {
      text = translate(context, "type_something");
    } else if (hasResults)
      text = translate(context, "select_suggestion");
    else {
      text = translate(context, "try_another_word");
    }

    AwesomeDialog(context: context, title: translate(context, text), desc: "")
        .show();
  }

  @override
  Widget buildResults(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0.0),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    //FocusScope.of(context).requestFocus(new FocusNode());
    return <Widget>[
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.delete_forever),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }
}
