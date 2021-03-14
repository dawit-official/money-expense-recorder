import 'package:flutter/semantics.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:expandable/expandable.dart';
import 'package:money_expense_recorder/database_helper.dart';
import 'package:money_expense_recorder/expenseCategory/expense_categories.dart';
import 'package:money_expense_recorder/expenseCategoryPage.dart';
import 'package:money_expense_recorder/expenseModel.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:money_expense_recorder/expense_form.dart';
import 'package:money_expense_recorder/widgets/loading_dialog.dart';

class ExpensePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  DateTime _firstDate;
  DateTime _lastDate;
  DatePeriod _selectedPeriod;
  Color selectedPeriodStartColor;
  Color selectedPeriodLastColor;
  Color selectedPeriodMiddleColor;
  List<ExpenseModel> _allExpenseList = List<ExpenseModel>();

  DateTime selectedPeriodStart = DateTime.now();
  DateTime selectedPeriodEnd = DateTime.now();
  String startMonth;
  String startDay;
  String endMonth;
  String endDay;
  setDateFields(){
    startMonth = selectedPeriodStart.month.toString();
    startDay = selectedPeriodStart.day.toString();
    endMonth = selectedPeriodEnd.month.toString();
    endDay = selectedPeriodEnd.day.toString();
    if(selectedPeriodStart.month<10){
      startMonth = "0"+selectedPeriodStart.month.toString();
    }
    if(selectedPeriodStart.day<10){
      startDay = "0"+selectedPeriodStart.day.toString();
    }
    if(selectedPeriodEnd.month<10){
      endMonth = "0"+selectedPeriodEnd.month.toString();
    }
    if(selectedPeriodEnd.day<10){
      endDay = "0"+selectedPeriodEnd.day.toString();
    }
    selectedPeriodStart = DateTime.parse(selectedPeriodStart.year.toString()+"-"+startMonth.toString()+"-"+startDay.toString()+" 00:00:00");
    selectedPeriodEnd = DateTime.parse(selectedPeriodEnd.year.toString()+"-"+endMonth.toString()+"-"+endDay.toString()+" 23:59:59");
    _selectedPeriod = DatePeriod(selectedPeriodStart, selectedPeriodEnd);
  }

  initializeExpenseList() async{
    _allExpenseList.clear();
    var expenseList = await dbHelper.getExpenseData();
    print("expenseList");
    print(expenseList);
//    var expenseList = await dbHelper.getFollowupModelInRangeData(_selectedPeriod.start,_selectedPeriod.end);
    if(expenseList!=null && expenseList.length>0){
      _allExpenseList = expenseList;
      _buildExpenseWidget(context,_allExpenseList);
    }
  }

  @override
  void initState() {
    super.initState();
    initializeExpenseList();
    _firstDate = DateTime.now().subtract(Duration(days: 3000));
    _lastDate = DateTime.now().add(Duration(days: 3000));
    setDateFields();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedPeriodLastColor = Theme.of(context).accentColor;
    selectedPeriodMiddleColor = Theme.of(context).accentColor;
    selectedPeriodStartColor = Theme.of(context).accentColor;
  }

  Future<Null> refresh() async {
    try {
      await initializeExpenseList();
      setState(() {

      });
    }catch(e){}
  }

  void showDeleteConfirmationDialog({BuildContext context, Widget child}) {
    showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((String value) {
      if (value != null) {}
    });
  }

  void _handleArchive() {}

  void _handleDelete() {}

  List notSelectedExpenses = new List();
  double selectedExpenseAmount = 0;
  _buildExpenseWidget(context,expenses) {
    selectedExpenseAmount = 0;
    final children = <Semantics>[];
    expenseChildren = <Semantics>[];
    expenses.forEach((ExpenseModel expense){
      String expenseDate = expense.expenseDate;
      String expenseTime = expense.expenseTime;
      if(expenseDate.toString()!=null && expenseDate.toString()!=""){
        DateTime _expenseDate = DateTime.parse(expenseDate.toString()+" "+expenseTime.toString());
        if((_expenseDate.isAtSameMomentAs(_selectedPeriod.start) || _expenseDate.isAtSameMomentAs(_selectedPeriod.end)) || (_expenseDate.isAfter(_selectedPeriod.start) && _expenseDate.isBefore(_selectedPeriod.end))){
          String expenseCategoryName = expense.expenseCategoryName;
          if(expense.expenseCategoryId==0){
            expenseCategoryName = expense.expenseReason;
          }
          int expenseId = expense.id;
          double expenseAmount = expense.expenseAmount;
          String expenseReason = expense.expenseReason;
          bool selectedExpense = true;
          var searchedExpense;
          if(notSelectedExpenses.length!=0){
            searchedExpense = notSelectedExpenses.where((element) => element==expenseId);
          }
          if(searchedExpense!=null && searchedExpense.isNotEmpty){
            selectedExpense = false;
          }else{
            selectedExpenseAmount = selectedExpenseAmount + expenseAmount.toDouble();
          }
          List<IconButton> applicableIcons = List<IconButton>();
          applicableIcons.add(
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.amber,
              ),
              onPressed: (){
                showFormDialog(context: context, child: ExpenseForm(expense,0));
              },
            ),
          );
          applicableIcons.add(
            IconButton(
              icon:
              Tooltip(
                message: "Delete",
                child: Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),
              ),
              onPressed: () async{
                if(expenseId!=0 && expenseId!=null){
                  showDeleteConfirmationDialog(
                    context: context,
                    child: CupertinoAlertDialog(
                      title: Text(translate("common.delete_expense")+'?'),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: Text(translate("button.delete")),
                          isDestructiveAction: true,
                          onPressed: () => deleteExpense(expense),
                        ),
                        CupertinoDialogAction(
                          child: Text(translate("button.cancel")),
                          isDefaultAction: true,
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          );
          DateTime expenseDateTime = DateTime.parse(expenseDate.toString()+" "+expenseTime.toString());
          Widget children2 = Semantics(
            customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
              const CustomSemanticsAction(label: 'Archive'): _handleArchive,
              const CustomSemanticsAction(label: 'Delete'): _handleDelete,
            },
            child: Dismissible(
              key: ObjectKey(expense),
              direction: DismissDirection.horizontal,
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart)
                  _handleArchive();
                else
                  _handleDelete();
              },
              confirmDismiss: (DismissDirection dismissDirection) async {
                switch(dismissDirection) {
                  case DismissDirection.endToStart:
                    if(expenseId!=0 && expenseId!=null){
                      showDeleteConfirmationDialog(
                        context: context,
                        child: CupertinoAlertDialog(
                          title: Text(translate("common.delete_expense")+'?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text(translate("button.delete")),
                              isDestructiveAction: true,
                              onPressed: () => deleteExpense(expense),
                            ),
                            CupertinoDialogAction(
                              child: Text(translate("button.cancel")),
                              isDefaultAction: true,
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                            ),
                          ],
                        ),
                      );
                    }
                    return false;
                  case DismissDirection.startToEnd:
                    showFormDialog(context: context, child: ExpenseForm(expense,0));
                    return false;
                  case DismissDirection.horizontal:
                  case DismissDirection.vertical:
                  case DismissDirection.up:
                  case DismissDirection.down:
                    assert(false);
                }
                return false;
              },
              background: Container(
                color: Colors.amber,
                child: const Center(
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.white, size: 36.0),
                  ),
                ),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                child: const Center(
                  child: ListTile(
                    trailing: Icon(Icons.delete, color: Colors.white, size: 36.0),
                  ),
                ),
              ),
              child: Container(
                  child: ExpandablePanel(
                    header:
                    Padding(
                      padding: EdgeInsets.only(left: 1.0, right: 1.0, bottom: 2.0),
                      child:
                      new Card(
                        child:
                        new ListTile(
                          leading:
                          Checkbox(
                            value: selectedExpense,
                            onChanged: (bool value) {
                              setState(() {
                                if(value==false){
                                  notSelectedExpenses.add(expenseId);
                                }else{
                                  notSelectedExpenses.removeWhere((element) => element==expenseId);
                                }
                                selectedExpense = value;
                                print(notSelectedExpenses);
                              });
                            },
                          ),
                          title: new Text(expenseCategoryName),
                          trailing: new Text(expenseAmount.toString()+" "+translate("common.etb")),
                          subtitle:
                          new Text(DateFormat.yMMMd().add_jm().format(expenseDateTime).toString(),style: TextStyle(fontSize: 11.0)),
                        ),
                      ),
                    ),
                    expanded:
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:  [
                          Wrap(
                            children: [
                              new Text(expenseReason,style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0)),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children:  applicableIcons
                          )
                        ]
                    ),
                  )
              ),
            ),
          );
          expenseChildren.add(children2);
        }
      }
    });
    return children;
  }

  deleteExpense(expense) async{
    if(expense.id!=0 && expense.id!=null){
      String message = "";
      Color messageColor = Colors.amber;
      LoadingDialog.show(context);
      await dbHelper.delete(DatabaseHelper.expenseTable, DatabaseHelper.columnId, expense.id).then((onValue){
        if(onValue==null){
          message = translate("common.expense_not_deleted");
          messageColor = Colors.red;
        }
        else {
          message = translate("common.expense_deleted_successfully");
          messageColor = Colors.lightGreen;
          Navigator.pop(context, 'Cancel');
          refresh();
        }
        flutterToastShowToast(message,messageColor);
        LoadingDialog.hide(context);
      });
    }
  }

  final ScrollController _scrollController2 = new ScrollController();
  var expenseChildren = <Semantics>[];

  @override
  Widget build(BuildContext context) {
    DatePickerRangeStyles styles = DatePickerRangeStyles(
      selectedPeriodLastDecoration: BoxDecoration(
          color: selectedPeriodLastColor,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0))),
      selectedPeriodStartDecoration: BoxDecoration(
        color: selectedPeriodStartColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
      ),
      selectedPeriodMiddleDecoration: BoxDecoration(
          color: selectedPeriodMiddleColor, shape: BoxShape.rectangle),
    );
    _buildExpenseWidget(context,_allExpenseList);
    return
    Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          new SizedBox(
              child: AppBar(
                  backgroundColor: Colors.blue,
                  centerTitle: true,
                  title: Row(children: [
                    new Text(translate("common.expense"), style: new TextStyle(color: Colors.white))
                  ]),
                  automaticallyImplyLeading: false,
                  actions: <Widget>[
                    MaterialButton(
                      child: Text("Category", style: TextStyle(color: Colors.white)),
//                      child: Icon(Icons.category,color: Colors.white,),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              ExpenseCategoryPage(),
                        ));
                      },
                    ),
                    MaterialButton(
                      child: Tooltip(
                        child: Icon(Icons.language,color: Colors.white,),
                        message: "Language Translation",
                      ),
                      onPressed: () {
                        _onActionSheetPress(context);
                        },
                    ),
                  ]
              )
          ),
          SizedBox(height: 10),
          ExpandableNotifier(  // <-- Provides ExpandableController to its children
            initialExpanded: true,
            child: Column(
              children: [
                Expandable(           // <-- Driven by ExpandableController from ExpandableNotifier
                  collapsed: ExpandableButton(  // <-- Expands when tapped on the cover photo
                    child: Container(
                        color: Colors.blue,
                        height: 25,
                        child: new Center(child: Text(DateFormat('MMM d, y').format(_selectedPeriod.start).toString()
                            +" "+translate("common.to")+" "+DateFormat('MMM d, y').format(_selectedPeriod.end).toString()
                            ,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500, color: Colors.white)))),
                  ),
                  expanded: Column(
                      children: [
                        ExpandableButton(       // <-- Collapses when tapped on
                          child: Center(
                              child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 150,
                                      child: RangePicker(
                                        selectedPeriod: _selectedPeriod,
                                        onChanged: _onSelectedDateChanged,
                                        firstDate: _firstDate,
                                        lastDate: _lastDate,
                                        datePickerStyles: styles,
                                      ),
                                    ),
                                    Container(
                                        height: 25,
                                        color: Colors.blue,
                                        child: new Center(child: Text(DateFormat('MMM d, y').format(_selectedPeriod.start).toString()
                                            +" "+translate("common.to")+" "+DateFormat('MMM d, y').format(_selectedPeriod.end).toString()
                                            ,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500, color: Colors.white)))),

                                  ])
                          ),
                        ),

                      ]
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20,5,0,0),
                child: Text(translate('common.expense_sum')+" :",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20,5,0,0),
                child: Text(selectedExpenseAmount.toString()+" "+translate("common.etb"),style: TextStyle(color: Colors.cyan,fontSize: 14,fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Expanded(child:
          Scrollbar(
              controller: _scrollController2,
              child:
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                controller: _scrollController2,
                itemCount: expenseChildren.length,
                itemBuilder: (context, index) {
                  final item = expenseChildren[index];
                  return item;
                },
              )
          )),
          SizedBox(height: 20,)
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async{
          expenseCategoryCodes.clear();
          final List<Map<String, dynamic>> expenseCategoryList = await dbHelper.getExpenseCategoriesData2();
          Map<String, dynamic> row = {
            DatabaseHelper.columnName : "Choose Category",
            DatabaseHelper.columnId  : 0,
          };
          expenseCategoryCodes.insert(0, row);
          for(var i=0;i<expenseCategoryList.length;i++){
            expenseCategoryCodes.insert(i+1, expenseCategoryList[i]);
          }
          ExpenseModel expense = new ExpenseModel();
          showFormDialog<FormDialogAction>(context: context, child: ExpenseForm(expense, 1));
        },
        child: new Tooltip(
            child: Icon(Icons.add),
            message: "New Expense"),
      ),
    );
  }

  void _onSelectedDateChanged(DatePeriod newPeriod){
    selectedPeriodStart = newPeriod.start;
    selectedPeriodEnd = newPeriod.end;
    setDateFields();
    setState(() {});
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void showFormDialog<T>({ BuildContext context, Widget child }) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    )
        .then<void>((T value) {
      refresh();
      if (value != null) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('You selected: $value'),
        ));
      }
    });
  }

  void showActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => child).then((String value)
    {
      changeLocale(context, value);
    });
  }

  void _onActionSheetPress(BuildContext context) {
    showActionSheet(
      context: context,
      child: CupertinoActionSheet(
        title: Text(translate('language.selection.title')),
        message: Text(translate('language.selection.message')),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(translate('language.name.en')),
            onPressed: () => Navigator.pop(context, 'en_US'),
          ),
          CupertinoActionSheetAction(
            child: Text(translate('language.name.am')),
            onPressed: () => Navigator.pop(context, 'am_ET'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(translate('button.cancel')),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, null),
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
