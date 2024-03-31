import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_assignment/models/github_event.dart';
import 'package:shimmer/shimmer.dart';

class FetchAndSortEvents {
  static Future<List<GithubEvent>> fetchAndSort(dynamic url) async {
    final dio = Dio();
    final response = await dio.get(url);
    final List<dynamic> jsonResponse = jsonDecode(response.data);
    return _sortGithubEvents(jsonResponse);
  }

  static List<GithubEvent> _sortGithubEvents(List<dynamic> jsonResponse) {
    return jsonResponse
        .map((json) => GithubEvent.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }
}

class LogScreen extends StatefulWidget {
  @override
  LogScreenState createState() => LogScreenState();
}

class LogScreenState extends State<LogScreen> {
  final StreamController<List<GithubEvent>> _streamController =
      StreamController<List<GithubEvent>>();
  final ScrollController _scrollController = ScrollController();
  List<GithubEvent> _allEvents = [];
  List<GithubEvent> _displayedEvents = [];
  final int _itemsPerPage = 20;
  final int _nextPageThreshold = 1;
  int _currentMaxIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAndProcessData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                _nextPageThreshold * 56.0 &&
        _currentMaxIndex < _allEvents.length) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    int nextMaxIndex = _currentMaxIndex + _itemsPerPage;
    if (nextMaxIndex > _allEvents.length) {
      nextMaxIndex = _allEvents.length;
    }
    _displayedEvents
        .addAll(_allEvents.getRange(_currentMaxIndex, nextMaxIndex).toList());
    _streamController.add(_displayedEvents);
    _currentMaxIndex = nextMaxIndex;
  }

  Future<void> _fetchAndProcessData() async {
    _allEvents = await compute(FetchAndSortEvents.fetchAndSort,
        'https://raw.githubusercontent.com/json-iterator/test-data/master/large-file.json');
    _loadMoreData(); // Load initial data
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'CreateEvent':
        return Colors.green;
      case 'PushEvent':
        return Colors.blue;
      case 'WatchEvent':
        return Colors.yellow;
      case 'ReleaseEvent':
        return Colors.orange;
      case 'PullRequestEvent':
        return Colors.purple;
      case 'IssuesEvent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<GithubEvent>>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Card(
                        color: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  height: 20,
                                  width: double.infinity,
                                  color: Colors.white),
                              const SizedBox(height: 5),
                              Container(
                                  height: 15,
                                  width: double.infinity,
                                  color: Colors.white),
                              const SizedBox(height: 5),
                              Container(
                                  height: 15,
                                  width: double.infinity,
                                  color: Colors.white)
                            ],
                          ),
                        ),
                      ),
                    ));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final event = snapshot.data![index];
              return Card(
                color: _getTypeColor(event.type),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.type,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text('${event.actorName} - ${event.createdAt}',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 5),
                      Text(event.payloadDescription,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    _scrollController.dispose();
    super.dispose();
  }
}
// This screen is implemented with the data fetch and sort done in the background and the partialy adding items to the UI list
// My idea was to partialy parse and sort the response and send the data back to the main thread from an isolate
// but since the reuqes is for the data to be sorted by Id I was unable do to that