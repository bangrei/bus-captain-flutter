/* Validation Rules
| -------------------------------------------------------------------------
| Add custom validation rules for your project in this file.
| Learn more https://nylo.dev/docs/5.20.0/validation#custom-validation-rules
|-------------------------------------------------------------------------- */

import 'package:nylo_framework/nylo_framework.dart';

final Map<String, dynamic> validationRules = {
  /// Example
  // "simple_password": (attribute) => SimplePassword(attribute),

  "match": (attibute) => MatchRule(attibute),
  "not_match": (attibute) => NotMatchRule(attibute),
};

/// Example validation class
// class SimplePassword extends ValidationRule {
//   SimplePassword(String attribute)
//       : super(
//       attribute: attribute,
//       signature: "simple_password", // Use this signature for the validator
//       description: "The $attribute field must be between 4 and 8 digits long", // Toast description when an error occurs
//       textFieldMessage: "Must be between 4 and 8 digits long with one numeric digit"); // TextField description when an error occurs
//
//   @override
//   bool handle(Map<String, dynamic> info) {
//     super.handle(info);
//
//     /// info['rule'] = Validation rule i.e "min".
//     /// info['data'] = Data the user has passed into the validation.
//     /// info['message'] = Overriding message to be displayed for validation (optional).
//
//     RegExp regExp = RegExp(r'^(?=.*\d).{4,8}$');
//     return regExp.hasMatch(info['data']);
//   }
// }

//MATCH RULE
class MatchRule extends ValidationRule {
  MatchRule(String attribute)
      : super(
            attribute: attribute,
            signature: "match",
            description: "",
            textFieldMessage: "");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(this.signature + r':([A-z0-9, ]+)');
    String match = regExp.firstMatch(info['rule'])?.group(1) ?? "";
    
    this.description = "$attribute not match";
    this.textFieldMessage = "not match.";
    super.handle(info);

    dynamic data = info['data'];
    if (data is String) {
      this.description = "$attribute not match";
      textFieldMessage = "not match.";
      super.handle(info);
      return (data == match);
    }

    if (data is int) {
      this.description = "$attribute not match";
      this.textFieldMessage = "not match.";
      super.handle(info);
      return (data == match);
    }

    if (data is List) {
      this.description = "$attribute not match";
      this.textFieldMessage = "not match.";
      super.handle(info);
      return (data == match);
    }

    if (data is Map) {
      this.description = "$attribute not match";
      this.textFieldMessage = "not match.";
      super.handle(info);
      return (data == match);
    }

    if (data is double) {
      this.description = "$attribute not match";
      this.textFieldMessage = "not match.";
      super.handle(info);
      return (data == match);
    }
    return false;
  }
}

//NOT MATCH RULE
class NotMatchRule extends ValidationRule {
  NotMatchRule(String attribute)
      : super(
            attribute: attribute,
            signature: "not_match",
            description: "",
            textFieldMessage: "");

  @override
  bool handle(Map<String, dynamic> info) {
    RegExp regExp = RegExp(this.signature + r':([A-z0-9, ]+)');
    String match = regExp.firstMatch(info['rule'])?.group(1) ?? "";
    
    this.description = "$attribute must be different";
    this.textFieldMessage = "New password must be different.";
    super.handle(info);

    dynamic data = info['data'];
    if (data is String) {
      this.description = "$attribute must be different";
      textFieldMessage = "New password must be different.";
      super.handle(info);
      return (data != match);
    }

    if (data is int) {
      this.description = "$attribute must be different";
      this.textFieldMessage = "New password must be different.";
      super.handle(info);
      return (data != match);
    }

    if (data is List) {
      this.description = "$attribute  must be different";
      this.textFieldMessage = " must be different.";
      super.handle(info);
      return (data != match);
    }

    if (data is Map) {
      this.description = "$attribute  must be different";
      this.textFieldMessage = "New password must be different.";
      super.handle(info);
      return (data != match);
    }

    if (data is double) {
      this.description = "$attribute must be different";
      this.textFieldMessage = "New password must be different.";
      super.handle(info);
      return (data != match);
    }
    return false;
  }
}
