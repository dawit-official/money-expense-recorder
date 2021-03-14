mixin ToAlias {}

@deprecated
class CElement = ExpenseCategory with ToAlias;

class ExpenseCategory {
  String name;
  int id;

  ExpenseCategory({
    this.name,
    this.id,
  });

  @override
  String toString() => "$name";

  String toLongString() => "$name";
}
