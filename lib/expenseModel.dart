class ExpenseModel {
  final int id;
  final String expenseDate;
  final String expenseTime;
  final double expenseAmount;
  final String expenseReason;
  final String expenseCategoryName;
  final int expenseCategoryId;
  ExpenseModel({this.id, this.expenseDate, this.expenseTime, this.expenseAmount, this.expenseReason, this.expenseCategoryName, this.expenseCategoryId});

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['_id'],
      expenseDate: json['expense_date'],
      expenseTime: json['expense_time'],
      expenseAmount: json['expense_amount'],
      expenseReason: json['expense_reason'],
      expenseCategoryName: json['expense_category_name'],
      expenseCategoryId: json['expense_category_id']
    );
  }
}