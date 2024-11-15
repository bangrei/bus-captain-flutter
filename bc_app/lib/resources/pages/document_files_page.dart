import 'dart:async';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/document_file.dart';
import 'package:bc_app/app/models/document_folder.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:bc_app/resources/widgets/documents_files_card_widget.dart';
import 'package:bc_app/resources/widgets/safearea_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DocumentFilesPage extends NyStatefulWidget {
  static const path = '/document-files';

  DocumentFilesPage({super.key})
      : super(path, child: _DocumentFilesPageState());
}

class _DocumentFilesPageState extends NyState<DocumentFilesPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isAscending = true;
  DocumentFolder? folder;
  List<DocumentFile> files = [];
  List<DocumentFile> filteredFiles = [];
  Function? onRefresh;
  Timer? _debounce;
  ApiController apiController = ApiController();

  @override
  init() async {}

  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    _searchController.addListener(_onSearchChanged);
    Map args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      onRefresh = args['onRefresh'];
      folder = args['folder'];
    });
    await _retrieveFiles();
  }

  _retrieveFiles() async {
    final res = await apiController.getDocumentFiles(context, folder!);
    setState(() {
      files = res;
      filteredFiles = _searchController.text.isEmpty
          ? files
          : files
              .where((i) => i.name
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
              .toList();
      filteredFiles.sort((a, b) {
        final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
        DateTime dateA = dateFormat.parse(a.timeAdded);
        DateTime dateB = dateFormat.parse(b.timeAdded);
        return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _onSearchSubmitted();
    });
  }

  void _onSearchSubmitted() async {
    await _retrieveFiles();
  }

  Future<void> _handleRefresh() async {
    await _retrieveFiles();
    return;
  }

  @override
  Widget view(BuildContext context) {
    //Sort data
    // filteredFiles.sort((a, b) {
    //   final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    //   DateTime dateA = dateFormat.parse(a.timeAdded);
    //   DateTime dateB = dateFormat.parse(b.timeAdded);
    //   return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    // });

    return Scaffold(
      appBar: TitleBar(
        title: folder!.name,
        backButtonLabel: "document_page.files_screen.files".tr(),
      ),
      body: SafeAreaWidget(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "document_page.files_screen.search".tr(),
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
          Container(
            width: 138,
            decoration: BoxDecoration(
              color: const Color(0xFFC4C4C4).withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () async {
                setState(() {
                  _isAscending = !_isAscending;
                });
              },
              child: Row(
                children: [
                  Text(
                    'document_page.files_screen.sort date'.tr(),
                    textScaler: TextScaler.noScaling,
                  ),
                  const SizedBox(width: 8),
                  if (_isAscending)
                    const Icon(
                      Icons.arrow_drop_up,
                      color: Colors.blue,
                    ),
                  if (!_isAscending)
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
              child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: filteredFiles.isEmpty
                ? Center(child: Text("no data".tr()))
                : ListView.builder(
                    itemCount: filteredFiles.length,
                    itemBuilder: (BuildContext context, int index) {
                      final file = filteredFiles[index];
                      return DocumentsFilesCard(file: file);
                    },
                  ),
          ))
        ],
      )),
    );
  }
}
