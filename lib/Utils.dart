
import 'package:flutter/cupertino.dart';

class Utils{
  static bool isEmpty(String text)=> text==""||text==null||text==" ";
  static bool validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value))
      return false;
    else
      return true;
  }
  static String calculateTimeDifferenceBetween(
      {required DateTime startDate, required DateTime endDate}) {
    int seconds = endDate.difference(startDate).inSeconds;
    if (seconds < 60)
      return '$seconds second ago';
    else if (seconds >= 60 && seconds < 3600)
      return '${startDate.difference(endDate).inMinutes.abs()} minute ago';
    else if (seconds >= 3600 && seconds < 86400) {
      if(startDate
          .difference(endDate)
          .inHours==1){
        return '${startDate
            .difference(endDate)
            .inHours} hour ago';
      }else{
        return '${startDate
            .difference(endDate)
            .inHours} hours ago';
      }

    } else{
      int d=startDate.difference(endDate).inDays;
      if(d==1){
        return '${startDate.difference(endDate).inDays} day ago';
      }else{
        return '${startDate.difference(endDate).inDays} days ago';
      }
    }

  }
}