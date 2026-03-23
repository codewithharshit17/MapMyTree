import 'package:flutter/material.dart';

class NgoDashboardProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;
  String _requestFilter = 'All';
  String _treeSearchQuery = '';

  int get selectedTabIndex => _selectedTabIndex;
  String get requestFilter => _requestFilter;
  String get treeSearchQuery => _treeSearchQuery;

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setRequestFilter(String filter) {
    _requestFilter = filter;
    notifyListeners();
  }

  void setTreeSearchQuery(String query) {
    _treeSearchQuery = query;
    notifyListeners();
  }
}
