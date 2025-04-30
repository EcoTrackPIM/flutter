import 'package:flutter/material.dart';
import '../Api/authApi.dart';
import 'loginScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/background.jpg",
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 70),
                Image.asset(
                  "assets/whiteLOGO.png",
                  width: 130,
                  height: 130,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.green,
                        width: 3, // Green top border 3px
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: Column(
                      children: [
                        Text(
                          "Create your account",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildTextField("Your Full Name", nameController),
                        const SizedBox(height: 12),
                        buildTextField("Your Email Address", emailController, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 12),
                        buildPasswordField(),
                        const SizedBox(height: 12),
                        buildTextField("Phone Number", phoneController, keyboardType: TextInputType.phone),
                        const SizedBox(height: 12),
                        buildTextField("Address", addressController),
                        const SizedBox(height: 12),
                        buildTextField("Age", ageController, keyboardType: TextInputType.number),
                        const SizedBox(height: 20),
                        buildSignUpButton(context),
                        const SizedBox(height: 15),
                        buildDivider(),
                        const SizedBox(height: 15),
                        buildSocialButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 45,
      child: ElevatedButton(
        onPressed: () async {
          try {
            final response = await apiService.registerUser(
              name: nameController.text,
              email: emailController.text,
              password: passwordController.text,
              phoneNumber: phoneController.text,
              address: addressController.text,
              age: int.tryParse(ageController.text),
            );

            if (response.isNotEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }
          } catch (e) {
            print("Error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Registration failed. Please try again.")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0B6E4F), Color(0xFF80C783)]),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget buildDivider() => const Divider(color: Colors.grey, thickness: 1);

  Widget buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: Image.asset("assets/facebook.png", width: 36), onPressed: () {}),
        const SizedBox(width: 20),
        IconButton(icon: Image.asset("assets/google.png", width: 36), onPressed: () {}),
      ],
    );
  }
}
