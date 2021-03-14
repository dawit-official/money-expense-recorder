import 'package:flutter/services.dart';
import 'package:money_expense_recorder/expenseCategoryModel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:money_expense_recorder/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:money_expense_recorder/database_helper.dart';
import 'package:flutter_translate/flutter_translate.dart';

class ExpenseCategoryForm extends StatefulWidget {
  final ExpenseCategoryModel expenseCategory;
  final int isNew;
  ExpenseCategoryForm(this.expenseCategory,this.isNew);

  @override
  _ExpenseCategoryFormState createState() {return _ExpenseCategoryFormState(expenseCategory,isNew);
  }
}

class _ExpenseCategoryFormState extends State<ExpenseCategoryForm> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  ExpenseCategoryModel expenseCategory;
  int isNew;
  _ExpenseCategoryFormState(this.expenseCategory,this.isNew);
  int expenseCategoryId;
  String expenseCategoryName;
  getFormFieldsData() async{
    expenseCategoryId = expenseCategory.id;
    if(expenseCategory!=null && isNew==0){
      expenseCategoryController.text = expenseCategory.name.toString();
    }else{
      expenseCategoryId = 0;
    }
  }

  Widget _buttons(context){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          fit: FlexFit.loose,
          child:
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>
              [
                CupertinoButton(
                  child: Text(translate('button.cancel'),style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoButton(
                  child: Text(translate('button.save')),
                  onPressed: () async{
                    if (_expenseCategoryFormKey.currentState.validate()) {
                      await checkRegistration(context).then((status){
                        if(status==1){
                          Navigator.of(context, rootNavigator: true).pop(FormDialogAction.agree);
                        }else if(status==2){
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                ),
              ]
          ),
        ),
      ],
    );
  }

  checkRegistration(context) async{
    var message = "";
    LoadingDialog.show(context);
    if(expenseCategoryId!=0 && expenseCategoryId!=null){
      _update(context,expenseCategoryId,expenseCategoryController.text);
      message = "Expense category updated";
      flutterToastShowToast(message,Colors.lightGreen);
      LoadingDialog.hide(context);
      return 2;
    }
    else{
      _insert(context,expenseCategoryController.text);
      LoadingDialog.hide(context);
      flutterToastShowToast("Expense category saved",Colors.lightGreen);
      return 2;
    }
  }

  void _insert(context,expenseCategoryName) async {
    Map<String, dynamic> row;
//   INSERT EXPENSE CATEGORY START
    if(expenseCategoryName!=null){
      row = {
        DatabaseHelper.columnName : expenseCategoryName,
      };
      await dbHelper.insert(""+DatabaseHelper.expenseCategoryTable,row);
    }
//   INSERT EXPENSE CATEGORY END
  }

  void _update(context,expenseCategoryId,expenseCategoryName) async {
    Map<String, dynamic> row;
//   INSERT EXPENSE CATEGORY START
    if(expenseCategoryName!=null){
      row = {
        DatabaseHelper.columnName : expenseCategoryName,
      };
      await dbHelper.update(""+DatabaseHelper.expenseCategoryTable,row,expenseCategoryId);
    }
//   INSERT EXPENSE CATEGORY END
  }

  final expenseCategoryController = TextEditingController();
  Widget _buildExpenseCategoryTextField() {
    return TextFormField(
      controller: expenseCategoryController,
      maxLines: null,
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        labelText: translate('common.expense_category_name'),
        hintText: translate('common.write_expense_category_name'),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return translate("common.write_expense_category_name");
        }
        return null;
      },
    );
  }

  int loadingChecker = 0;
  final _expenseCategoryFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    if(loadingChecker==0){
      getFormFieldsData();
      loadingChecker = 1;
    }
    return Scaffold(
      drawerDragStartBehavior: DragStartBehavior.down,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        automaticallyImplyLeading: false,
        title: _buttons(context),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child:
        new GestureDetector(
            excludeFromSemantics: true,
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child:
            DefaultTextStyle(
              style: CupertinoTheme.of(context).textTheme.textStyle,
              child: CupertinoPageScaffold(
                child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).brightness == Brightness.light
                          ? CupertinoColors.extraLightBackgroundGray
                          : CupertinoColors.darkBackgroundGray,
                    ),
                    child:
                    CustomScrollView
                      (
                      slivers: <Widget>
                      [
                        SliverList
                          (
                          delegate: SliverChildListDelegate
                            (
                              <Widget>
                              [
                                Flex(
                                  direction: MediaQuery.of(context).orientation == Orientation.portrait
                                      ? Axis.vertical
                                      : Axis.horizontal,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(12,20,12,0),
                                          child: Container(
                                            color: Colors.white,
                                            child: Column(
                                                children: <Widget>[
                                                  Form(
                                                    key: _expenseCategoryFormKey,
                                                    child: Scrollbar(
                                                      child: SingleChildScrollView(
                                                        dragStartBehavior: DragStartBehavior.down,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                        child: new ClipPath(
                                                          clipper: MyClipper(),
                                                          child:
                                                          Container(
                                                            alignment: Alignment.center,
                                                            padding: EdgeInsets.fromLTRB(0,0,0,0),
                                                            child:
                                                            Column(
                                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                children: <Widget>[
                                                                  const SizedBox(height: 20.0),
                                                                  _buildExpenseCategoryTextField(),
                                                                  const SizedBox(height: 15.0),
                                                                ]),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ]
                          ),
                        ),
                      ],
                    )
                ),
              ),
            )
        ),
      ),
    );
  }

  flutterToastShowToast(message,color){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}

enum FormDialogAction {
  cancel,
  discard,
  disagree,
  agree,
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = new Path();
    p.lineTo(size.width, 10.0);
    p.lineTo(size.width, size.height * 0.85);
    p.arcToPoint(
      Offset(0.0, size.height * 30.85),
      radius: const Radius.circular(10),
      rotation: 0.0,
    );
    p.lineTo(0.0, 0.0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}