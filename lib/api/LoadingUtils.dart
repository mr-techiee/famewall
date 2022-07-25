
import 'package:event_bus/event_bus.dart';
import 'package:famewall/api/LoadingIndicator.dart';
import 'package:flutter/material.dart';
EventBus eventBus = EventBus();

class LoadingUtils {
  BuildContext? context;
  static LoadingUtils _instance = LoadingUtils._();
  LoadingUtils._();
  static LoadingUtils get instance => _instance;
  void showLoadingIndicator(String text) {
    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return  AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          backgroundColor: Colors.black87,
          content: LoadingIndicator(
              text: text
          ),
        );
      },
    );
  }
  void showToast(text){
    ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }
  void hideOpenDialog() {
    Navigator.of(context!, rootNavigator: true).pop('dialog');
  }
  void setContext(BuildContext context){
    this.context=context;
  }
}