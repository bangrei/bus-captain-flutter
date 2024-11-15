import 'dart:async';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/document_folder.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:bc_app/resources/widgets/documents_card_widget.dart';
import 'package:bc_app/resources/widgets/safearea_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DocumentPage extends NyStatefulWidget {
  static const path = '/document';

  DocumentPage({super.key}) : super(path, child: _DocumentPageState());
}

class _DocumentPageState extends NyState<DocumentPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Timer? _debounce;
  List<DocumentFolder> folders = [];
  List<DocumentFolder> filteredFolders = [];
  ApiController apiController = ApiController();

  @override
  init() async {}

  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    _searchController.addListener(_onSearchChanged);
    _retrieveDocuments();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _onSearchSubmitted();
    });
  }

  void _onSearchSubmitted() async {
    doFilter();
  }

  _retrieveDocuments() async {
    final res = await apiController.getFolders(context);
    setState(() {
      folders = res;
    });
    doFilter();
  }

  void doFilter() {
    List<DocumentFolder> res = folders;
    if (_searchController.text.isNotEmpty) {
      res = folders
          .where((i) => i.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredFolders = res;
    });
  }

  Future<void> _handleRefresh() async {
    _refreshIndicatorKey.currentState?.show();
    await _retrieveDocuments();
    return Future.value();
  }

  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      body: SafeAreaWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "document_page.folder_screen.title".tr(),
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins-Bold",
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "document_page.folder_screen.search".tr(),
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: nyHexColor('f5f5f5'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _handleRefresh,
                child: filteredFolders.isEmpty
                    ? Center(child: Text("no data".tr()))
                    : ListView.builder(
                        itemCount: filteredFolders.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = filteredFolders[index];
                          return DocumentsCard(
                              item: item, onRefresh: _retrieveDocuments);
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
