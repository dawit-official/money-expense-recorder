import 'package:flutter/semantics.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:money_expense_recorder/database_helper.dart';
import 'package:money_expense_recorder/expenseCategoryModel.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:money_expense_recorder/expense_category_form.dart';
import 'package:money_expense_recorder/widgets/loading_dialog.dart';

class ExpenseCategoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpenseCategoryPageState();
}

class _ExpenseCategoryPageState extends State<ExpenseCategoryPage> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  _buildSingleExpenseCategoryWidget(expenseCategory){
    String expenseCategoryName = expenseCategory.name;
    int expenseCategoryId = expenseCategory.id;
    Widget children = Semantics(
      customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
        const CustomSemanticsAction(label: 'Archive'): _handleArchive,
        const CustomSemanticsAction(label: 'Delete'): _handleDelete,
      },
      child: Dismissible(
        key: ObjectKey(expenseCategory),
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
              if(expenseCategoryId!=0 && expenseCategoryId!=null){
                showDeleteConfirmationDialog(
                  context: context,
                  child: CupertinoAlertDialog(
                    title: Text(translate("common.delete_expense_category")+'?'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text(translate("button.delete")),
                        isDestructiveAction: true,
                        onPressed: () => deleteExpenseCategory(expenseCategory),
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
              showFormDialog(context: context, child: ExpenseCategoryForm(expenseCategory,0));
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
          child:
          Padding(
            padding: EdgeInsets.only(left: 1.0, right: 1.0, bottom: 2.0),
            child:
            new Card(
              child:
              new ListTile(
                leading:
                Icon(Icons.arrow_right),
                title: new Text(expenseCategoryName),
              ),
            ),
          ),
        ),
      ),
    );
    return children;
  }

  deleteExpenseCategory(expenseCategory) async{
    if(expenseCategory.id!=0 && expenseCategory.id!=null){
      String message = "";
      Color messageColor = Colors.amber;
      LoadingDialog.show(context);
      await dbHelper.delete(DatabaseHelper.expenseCategoryTable, DatabaseHelper.columnId, expenseCategory.id).then((onValue){
        if(onValue==null){
          message = translate("common.expense_category_not_deleted");
          messageColor = Colors.red;
        }
        else {
          message = translate("common.expense_category_deleted_successfully");
          messageColor = Colors.lightGreen;
          Navigator.pop(context, 'Cancel');
          setState(() {});
        }
        flutterToastShowToast(message,messageColor);
        LoadingDialog.hide(context);
      });
    }
  }

  final ScrollController _scrollController = new ScrollController();
  var expenseCategoryChildren = <Semantics>[];

  @override
  Widget build(BuildContext context) {
    return
    Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          new SizedBox(
              child: AppBar(
                  backgroundColor: Colors.blue,
                  centerTitle: true,
                  title: new Text(translate("common.expense_category"), style: new TextStyle(color: Colors.white)),
                  automaticallyImplyLeading: true,
                  actions: <Widget>[]
              )
          ),
          SizedBox(height: 10),
          Expanded(child:
          FutureBuilder<List>(
            future: dbHelper.getExpenseCategoriesData(),
            initialData: List(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                controller: _scrollController,
                itemCount: snapshot.data.length,
                itemBuilder: (_, int position) {
                  final expenseCategory = snapshot.data[position];
                  return _buildSingleExpenseCategoryWidget(expenseCategory);
                },
              )
                  : Center(
                child: Text(translate('common.no_data')),
              );
            },
          ),
          ),
          SizedBox(height: 20,)
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          ExpenseCategoryModel expenseCategory = new ExpenseCategoryModel();
          showFormDialog<FormDialogAction>(context: context, child: ExpenseCategoryForm(expenseCategory, 1));
        },
        child: new Icon(Icons.add),
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void showFormDialog<T>({ BuildContext context, Widget child }) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    )
        .then<void>((T value) {
      setState(() {});
      if (value != null) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('You selected: $value'),
        ));
      }
    });
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
