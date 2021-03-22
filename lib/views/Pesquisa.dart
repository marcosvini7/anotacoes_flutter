import 'package:flutter/material.dart';

class Pesquisa extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Pesquise por anotações';

  @override
  TextStyle get searchFieldStyle => TextStyle(
      color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.normal);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future.delayed(Duration(milliseconds: 10), () {
      close(context, query);
    });
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
