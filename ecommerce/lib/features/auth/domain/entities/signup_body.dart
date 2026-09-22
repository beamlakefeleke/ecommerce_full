/// Pure Dart entity representing a sign-up request body.
///
/// No JSON serialization — that lives in `data/models/signup_body_model.dart`.
class SignupBody {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  final String refCode;

  const SignupBody({
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email = '',
    required this.password,
    this.refCode = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignupBody &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          phone == other.phone &&
          email == other.email &&
          password == other.password &&
          refCode == other.refCode;

  @override
  int get hashCode =>
      Object.hash(firstName, lastName, phone, email, password, refCode);
}
