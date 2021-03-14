library expense_category_picker;

import 'package:money_expense_recorder/expenseCategory/expense_category.dart';
import 'package:money_expense_recorder/expenseCategory/expense_categories.dart';
import 'package:money_expense_recorder/expenseCategory/selection_dialog.dart';
import 'package:flutter/material.dart';

export 'expense_category.dart';

class ExpenseCategoryPicker extends StatefulWidget {
  final ValueChanged<ExpenseCategory> onChanged;
  final String initialSelection;
  final List<String> favorite;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;
  final bool showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final WidgetBuilder emptySearchBuilder;

  /// shows the name of the country instead of the dialcode
  final bool showOnlyCountryWhenClosed;

  /// aligns the flag and the Text left
  ///
  /// additionally this option also fills the available space of the widget.
  /// this is especially usefull in combination with [showOnlyCountryWhenClosed],
  /// because longer countrynames are displayed in one line
  final bool alignLeft;

  /// shows the flag
  final bool showFlag;

  ExpenseCategoryPicker({
    this.onChanged,
    this.initialSelection,
    this.favorite = const [],
    this.textStyle,
    this.padding = const EdgeInsets.all(0.0),
    this.showCountryOnly = false,
    this.searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.emptySearchBuilder,
    this.showOnlyCountryWhenClosed = false,
    this.alignLeft = false,
    this.showFlag = true
  });

  @override
  State<StatefulWidget> createState() {
    List<Map> jsonList = expenseCategoryCodes;

    List<ExpenseCategory> elements = jsonList
        .map((s) => ExpenseCategory(
      name: s['name'],
      id: s['id']
    ))
        .toList();

    return new _ExpenseCategoryPickerState(elements);
  }
}

class _ExpenseCategoryPickerState extends State<ExpenseCategoryPicker> {
  ExpenseCategory selectedItem;
  List<ExpenseCategory> elements = [];
  List<ExpenseCategory> favoriteElements = [];

  _ExpenseCategoryPickerState(this.elements);

  @override
  Widget build(BuildContext context) => FlatButton(
    child: Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(),
        Flexible(
            fit: widget.alignLeft ? FlexFit.tight : FlexFit.loose,
            child:
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    selectedItem.toString(),
                    style: widget.textStyle ?? Theme.of(context).textTheme.button,
                  ),
                  Icon(Icons.arrow_drop_down,color: Colors.black45)
                ])
        ),
      ],
    ),
    padding: widget.padding,
    onPressed: _showSelectionDialog,
  );

  @override
  initState() {
    if (widget.initialSelection != null) {
      selectedItem = elements.firstWhere(
              (e) =>
          (e.name.toUpperCase() == widget.initialSelection.toUpperCase()),
          orElse: () => elements[0]);
    } else {
      if(elements!=null && elements.length>0){
        selectedItem = elements[0];
      }
    }

    favoriteElements = elements
        .where((e) =>
    widget.favorite.firstWhere(
            (f) => e.name == f.toUpperCase(),
        orElse: () => null) !=
        null)
        .toList();
    super.initState();
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) =>
          ExpenseCategorySelectionDialog(
              elements,
              favoriteElements,
              showCountryOnly: widget.showCountryOnly,
              emptySearchBuilder: widget.emptySearchBuilder,
              searchDecoration: widget.searchDecoration,
              searchStyle: widget.searchStyle,
              showFlag: widget.showFlag
          ),
    ).then((e) {
      if (e != null) {
        setState(() {
          selectedItem = e;
        });

        _publishSelection(e);
      }
    });
  }

  void _publishSelection(ExpenseCategory e) {
    if (widget.onChanged != null) {
      widget.onChanged(e);
    }
  }
}
