import 'package:flutter/material.dart';
import 'package:money_expense_recorder/expenseCategory/expense_category.dart';

/// selection dialog used for selection of the country code
class ExpenseCategorySelectionDialog extends StatefulWidget {
  final List elements;
//  final List<ExpenseCategory> elements;
  final bool showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final WidgetBuilder emptySearchBuilder;
  final bool showFlag;

  /// elements passed as favorite
  final List favoriteElements;
//  final List<ExpenseCategory> favoriteElements;

  ExpenseCategorySelectionDialog(this.elements, this.favoriteElements, {
    Key key,
    this.showCountryOnly,
    this.emptySearchBuilder,
    InputDecoration searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.showFlag
  }) :
        assert(searchDecoration != null, 'searchDecoration must not be null!'),
        this.searchDecoration = searchDecoration.copyWith(prefixIcon: Icon(Icons.search)),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _ExpenseCategorySelectionDialogState();
}

class _ExpenseCategorySelectionDialogState extends State<ExpenseCategorySelectionDialog> {
  /// this is useful for filtering purpose
  List<ExpenseCategory> filteredElements;

  @override
  Widget build(BuildContext context) => SimpleDialog(
    title: Column(
      children: <Widget>[
        TextField(
          style: widget.searchStyle,
          decoration: widget.searchDecoration,
          onChanged: _filterElements,
        ),
      ],
    ),
    children: [
      Container(
          width: MediaQuery.of(context).size.width,
          height: 250,
          child: ListView(
              children: [
                widget.favoriteElements.isEmpty
                    ? const DecoratedBox(decoration: BoxDecoration())
                    : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[]
                      ..addAll(widget.favoriteElements
                          .map(
                            (f) => SimpleDialogOption(
                          child: _buildOption(f),
                          onPressed: () {
                            _selectItem(f);
                          },
                        ),
                      )
                          .toList())
                      ..add(const Divider())),
              ]..addAll(filteredElements.isEmpty
                  ? [_buildEmptySearchWidget(context)]
                  : filteredElements.map(
                      (e) => SimpleDialogOption(
                    key: Key(e.toLongString()),
                    child: _buildOption(e),
                    onPressed: () {
                      _selectItem(e);
                    },
                  )))
          )
      ),
    ],
  );

  Widget _buildOption(ExpenseCategory e) {
    return Container(
      width: 400,
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(),
//          Expanded(
//            flex: 4,
//            child:
            Text(
              e.toLongString(),
              overflow: TextOverflow.fade,
            ),
//          ),
          Divider(thickness: 1),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder(context);
    }

    return Center(child: Text('No Method Found'));
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements
          .where((e) =>
          e.name.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(ExpenseCategory e) {
    Navigator.pop(context, e);
  }
}
