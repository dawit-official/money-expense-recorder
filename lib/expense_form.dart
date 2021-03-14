import 'package:flutter/services.dart';
import 'package:money_expense_recorder/expenseModel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:money_expense_recorder/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:money_expense_recorder/expenseCategory/expense_category_picker.dart';
import 'package:money_expense_recorder/expenseCategory/expense_categories.dart';
import 'package:money_expense_recorder/date_and_time_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:money_expense_recorder/database_helper.dart';
import 'package:flutter_translate/flutter_translate.dart';

class ExpenseForm extends StatefulWidget {
  final ExpenseModel expense;
  final int isNew;
  ExpenseForm(this.expense,this.isNew);

  @override
  _ExpenseFormState createState() {return _ExpenseFormState(expense,isNew);
  }
}

class _ExpenseFormState extends State<ExpenseForm> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  ExpenseModel expense;
  int isNew;
  _ExpenseFormState(this.expense,this.isNew);
  int expenseId;
  int expenseCategoryId;
  String expenseCategoryName;

  @override
  void initState(){
    super.initState();
  }

  getFormFieldsData() async{
    expenseId = expense.id;
    if(expense!=null && isNew==0){
      _expenseDate = DateTime.parse(expense.expenseDate+" "+expense.expenseTime);
      _expenseTime = new TimeOfDay.fromDateTime(_expenseDate);
      expenseCategoryId = expense.expenseCategoryId;
      expenseCategoryName = expense.expenseCategoryName;
      expenseId = expense.id;
      expenseReasonController.text = expense.expenseReason.toString();
      expenseAmountController.text = expense.expenseAmount.toString();
    }else{
      expenseCategoryId = expenseCategoryCodes[0]["_id"];
      expenseCategoryName = expenseCategoryCodes[0]["name"];
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
                    if (_expenseFormKey.currentState.validate()) {
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
    if(expenseId!=0 && expenseId!=null){
      _update(context,expense,_expenseDate,_expenseTime,expenseCategoryId,expenseCategoryName,expenseReasonController.text,expenseAmountController.text);
      message = "Expense updated";
      flutterToastShowToast(message,Colors.lightGreen);
      LoadingDialog.hide(context);
      return 2;
    }
    else{
      _insert(context,_expenseDate,_expenseTime,expenseCategoryId,expenseCategoryName,expenseReasonController.text,expenseAmountController.text);
      LoadingDialog.hide(context);
      flutterToastShowToast("Expense saved",Colors.lightGreen);
      return 2;
    }
  }

  void _insert(context,expenseDate,expenseTime,expenseCategoryId,expenseCategoryName,expenseReason,expenseAmount) async {
    Map<String, dynamic> row;
//   INSERT EXPENSE START
    if(expenseReason!=null){
      String month = expenseDate.month.toString();
      String day = expenseDate.day.toString();
      String hour = expenseTime.hour.toString();
      String minute = expenseTime.minute.toString();
      if(expenseDate.month<10){
        month = "0"+expenseDate.month.toString();
      }if(expenseDate.day<10){
        day = "0"+expenseDate.day.toString();
      }if(expenseTime.hour<10){
        hour = "0"+expenseTime.hour.toString();
      }if(expenseTime.minute<10){
        minute = "0"+expenseTime.minute.toString();
      }
      if(expenseCategoryId==0){
        expenseCategoryName = "";
      }
      row = {
        DatabaseHelper.columnExpenseDate : expenseDate.year.toString()+"-"+month.toString()+"-"+day.toString(),
        DatabaseHelper.columnExpenseTime : hour.toString()+":"+minute.toString(),
        DatabaseHelper.columnExpenseReason : expenseReason,
        DatabaseHelper.columnExpenseCategoryId : expenseCategoryId,
        DatabaseHelper.columnExpenseCategoryName : expenseCategoryName,
        DatabaseHelper.columnExpenseAmount : expenseAmount,
      };
      await dbHelper.insert(""+DatabaseHelper.expenseTable,row);
    }
//   INSERT EXPENSE END
  }

  void _update(context,expense,expenseDate,expenseTime,expenseCategoryId,expenseCategoryName,expenseReason,expenseAmount) async {
    Map<String, dynamic> row;
//   INSERT EXPENSE START
    if(expenseReason!=null){
      String month = expenseDate.month.toString();
      String day = expenseDate.day.toString();
      String hour = expenseTime.hour.toString();
      String minute = expenseTime.minute.toString();
      if(expenseDate.month<10){
        month = "0"+expenseDate.month.toString();
      }if(expenseDate.day<10){
        day = "0"+expenseDate.day.toString();
      }if(expenseTime.hour<10){
        hour = "0"+expenseTime.hour.toString();
      }if(expenseTime.minute<10){
        minute = "0"+expenseTime.minute.toString();
      }
      if(expenseCategoryId==0){
        expenseCategoryName = "";
      }
      row = {
        DatabaseHelper.columnExpenseDate : expenseDate.year.toString()+"-"+month.toString()+"-"+day.toString(),
        DatabaseHelper.columnExpenseTime : hour.toString()+":"+minute.toString(),
        DatabaseHelper.columnExpenseReason : expenseReason,
        DatabaseHelper.columnExpenseAmount : expenseAmount,
        DatabaseHelper.columnExpenseCategoryId : expenseCategoryId,
        DatabaseHelper.columnExpenseCategoryName : expenseCategoryName
      };
      await dbHelper.update(""+DatabaseHelper.expenseTable,row,expense.id);
    }
//   INSERT PROSPECT FOLLOWUP END
  }

  Widget _buildExpenseCategoryPicker(){
    void setExpenseCategory(object) {
      setState(() {
        expenseCategoryId = object.id;
        expenseCategoryName = object.name;
      });
    }
    return
      Container(
        child: ExpenseCategoryPicker(
          padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
          textStyle: TextStyle(fontSize: 15.0,fontWeight: FontWeight.w400),
          onChanged: setExpenseCategory,
          initialSelection: expenseCategoryName,
        ),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: Colors.grey,width: 0.5),
        ),
      );
  }

  Widget _buildExpenseDateTimePicker(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Text(translate('common.expense_date'),style: TextStyle(fontSize: 14,color: Colors.black45),)
          ),
          DateTimePicker(
            selectedDate: _expenseDate,
            selectedTime: _expenseTime,
            selectDate: (DateTime date) {
              setState(() {
                _expenseDate = date.toLocal();
              });
            },
            selectTime: (TimeOfDay time) {
              setState(() {
                _expenseTime = time;
              });
            },
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: Colors.grey,width: 0.5),
      ),
    );
  }

  final expenseReasonController = TextEditingController();
  Widget _buildExpenseReasonTextField() {
    return TextFormField(
      controller: expenseReasonController,
      minLines: 3,
      maxLines: null,
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        labelText: translate('common.expense_reason'),
        hintText: translate('common.write_expense_reason'),
      ),
//      validator: (value) {
//        if (value.isEmpty) {
//          return translate("common.write_expense_reason");
//        }
//        return null;
//      },
    );
  }

  final expenseAmountController = TextEditingController();
  Widget _buildExpenseAmountTextField() {
    return TextFormField(
      controller: expenseAmountController,
//      minLines: 3,
      maxLines: null,
      keyboardType: TextInputType.number,
//      inputFormatters: <TextInputFormatter>[
//        FilteringTextInputFormatter.digitsOnly
//      ], // Only numbers can be entered
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        labelText: translate('common.expense_amount'),
        hintText: translate('common.enter_expense_amount'),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return translate("common.enter_expense_amount");
        }
        return null;
      },
    );
  }

  int loadingChecker = 0;
  DateTime _expenseDate = DateTime.now();
  TimeOfDay _expenseTime = const TimeOfDay(hour: 7, minute: 28);
  final _expenseFormKey = GlobalKey<FormState>();
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
                                                    key: _expenseFormKey,
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
                                                                  _buildExpenseCategoryPicker(),
                                                                  const SizedBox(height: 15.0),
                                                                  _buildExpenseDateTimePicker(),
                                                                  const SizedBox(height: 15.0),
                                                                  _buildExpenseAmountTextField(),
                                                                  const SizedBox(height: 15.0),
                                                                  _buildExpenseReasonTextField(),
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