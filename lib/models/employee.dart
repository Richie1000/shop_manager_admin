class Employee {
  final String id;
  final String email;
  //final double phoneNumber;
  final String role;

  Employee(
      {required this.id,
      required this.email,
      //required this.phoneNumber,
      required this.role});

  factory Employee.fromFirestore(Map<String, dynamic> data, String id) {
    return Employee(id: id, email: data["email"], role: data["role"]);
  }

  Map<String, dynamic> toMap() {
    return {"email": email, "role": role};
  }
}
