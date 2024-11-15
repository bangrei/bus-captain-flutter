import 'package:bc_app/app/models/document_folder.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/document_files_page.dart';
import 'package:flutter/material.dart';

class DocumentsCard extends StatelessWidget {
  final DocumentFolder item;
  final Function onRefresh;
  const DocumentsCard({
    super.key,
    required this.item,
    required this.onRefresh
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context, 
        DocumentFilesPage.path,
        arguments: {
          "folder": item,
          "onRefresh": onRefresh
        }
      ),
      child: Card(
        color: ThemeColor.get(context).cardBg,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10.0),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black12, width: 0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.folder, 
                    color: Color(0xFF75A8D7)
                  ),
                  const SizedBox(width: 20),
                  Text(item.name),
                ],
              ),
              const Icon(
                Icons.keyboard_arrow_right,
                color: Color(0xFFCECECE),
              )
            ],
          ),
        ),
      ),
    );
  }
}
