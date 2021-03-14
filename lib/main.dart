import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_translate/localization_delegate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:money_expense_recorder/expensePage.dart';
import 'package:money_expense_recorder/expenseModel.dart';
import 'package:money_expense_recorder/expense_form.dart';

void main() async{
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en_US',
      supportedLocales: ['en_US', 'am_ET']
  );
  runApp(LocalizedApp(delegate,
    MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
      theme: new ThemeData(primaryColor: Colors.blue),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return ExpensePage();
//    return Scaffold(
//      backgroundColor: Colors.white,
//      body: ExpensePage(),
//      floatingActionButton: new FloatingActionButton(
//        backgroundColor: Colors.blue,
//        onPressed: () {
//          ExpenseModel expense = new ExpenseModel();
//          showFormDialog<FormDialogAction>(context: context, child: ExpenseForm(expense, 1));
//        },
//        child: new Icon(Icons.add),
//      ),
//    );
  }

//final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//void showFormDialog<T>({ BuildContext context, Widget child }) {
//  showDialog<T>(
//    context: context,
//    builder: (BuildContext context) => child,
//  )
//      .then<void>((T value) {
//        print("tttttttttttttttt");
//        setState(() {});
//    if (value != null) {
//      _scaffoldKey.currentState.showSnackBar(SnackBar(
//        content: Text('You selected: $value'),
//      ));
//    }
//  });
//}
}

//enum FormDialogAction {
//  cancel,
//  discard,
//  disagree,
//  agree,
//}
