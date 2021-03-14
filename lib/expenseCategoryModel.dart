class ExpenseCategoryModel {
  final int id;
  final String name;
  ExpenseCategoryModel({this.id, this.name});

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['_id'],
      name: json['name']
    );
  }
}