import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/widgets/components/section_divider_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class QuestionItem {
  QuestionItem({required this.question, required this.answer, this.isExpanded = false});
  String question;
  String answer;
  bool isExpanded;
}
class HelpPage extends NyStatefulWidget {
  static const path = '/help';
  
  HelpPage({super.key}) : super(path, child: _HelpPageState());
}

class _HelpPageState extends NyState<HelpPage> {
  int numOfQuestions = 2;
  List<QuestionItem> _qsnItems = [];
  @override
  init() async {
    _qsnItems = List.generate(numOfQuestions,
      (int index) {
        return QuestionItem(
          question:"help_page.questions.question${index+1}.question".tr() ,
          answer: "help_page.questions.question${index+1}.answer".tr()
        );
      }
    );
  }
  
  /// Use boot if you need to load data before the [view] is rendered.
  // @override
  // boot() async {
  //
  // }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: "help_page.title".tr()),
      body: SafeArea(
         child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                // decoration: BoxDecoration(border: Border.all(width: 1)),
                child: Text("help_page.subtitle".tr(),
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: nyHexColor("8F8F8F"),
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height:20),
              const SectionDivider(),
              Column(
                children: _qsnItems.map<Widget>(
                  (QuestionItem item) {
                    return Column(
                      children: [
                        ExpansionTile(
                          title: Text(
                            item.question,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                              fontFamily: "Poppins-Bold",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Icon(
                            item.isExpanded ? Icons.close_sharp: Icons.add,
                            color: ThemeColor.get(context).helpPageIcon,
                          ),
                          onExpansionChanged: (bool isExpanded) {
                            setState(() {
                              item.isExpanded = isExpanded;
                            });
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ListTile(
                                title: Text(
                                  item.answer,
                                  textScaler: TextScaler.noScaling,
                                  style: TextStyle(
                                    color: ThemeColor.get(context).primaryContent
                                  ),
                                )
                              ),
                            )
                          ],
                        ),
                        const SectionDivider()
                      ],
                    );
                  }
                ).toList()
              )
            ],
          ),
         ),
      ),
    );
  }
}
