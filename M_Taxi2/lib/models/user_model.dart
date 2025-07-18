class UserModel {
  String? firstName;
  String? lastName;
  String? phone;
  String? address;
  String? email;
  String? password;
  String? avatarUrl;
  String? cardNumber;
  String? cardExpiry;

  UserModel({
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.email,
    this.password,
    this.avatarUrl,
    this.cardNumber,
    this.cardExpiry,
  });

  // SharedPreferences-dan ma'lumotlarni yuklash
  static Future<UserModel> loadFromPrefs() async {
    // Bu yerda SharedPreferences dan ma'lumotlarni o'qib, UserModel qaytarishingiz kerak
    // Misol uchun:
    // final prefs = await SharedPreferences.getInstance();
    return UserModel(
      firstName: '', // prefs.getString('firstName'),
      lastName: '',  // prefs.getString('lastName'),
      // ...
    );
  }

  // Ma'lumotlarni SharedPreferences-ga saqlash
  Future<void> saveToPrefs() async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('firstName', firstName ?? '');
    // await prefs.setString('lastName', lastName ?? '');
    // ...
  }
}