/// RegisterData model to hold registration form data
class RegisterData {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String accountType;

  RegisterData({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.accountType,
  });
}
