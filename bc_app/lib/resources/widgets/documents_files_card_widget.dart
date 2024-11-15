import 'package:bc_app/app/models/document_file.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/document_view_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';

class DocumentsFilesCard extends StatelessWidget {
  final DocumentFile file;
  const DocumentsFilesCard({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, DocumentViewPage.path, arguments: {
          'doc': file,
        });
      },
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
                  const Icon(Icons.text_snippet_outlined,
                      color: Color(0xFF1570EF)),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                            color: Color(0xFF4D5A69),
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            file.owner,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 5.0),
                          const Icon(Icons.circle,
                              size: 5.0, color: Colors.grey),
                          const SizedBox(width: 5.0),
                          Text(
                            dateFormatString(
                              file.timeAdded,
                              fromFormat: 'yyyy-MM-dd HH:mm:ss',
                              toFormat: 'dd MMM yyyy HH:mm a',
                            ),
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  ),
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
