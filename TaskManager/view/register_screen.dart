import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/databasehelper.dart';
import '../models/User.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final db = DatabaseHelper.instance;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final user = User(
        id: const Uuid().v4(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        email: _emailController.text.trim(),
        avatar: null,
        createdAt: now,
        lastActive: now,
      );

      await db.insertUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công!")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký tài khoản")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Tên đăng nhập"),
                validator: (value) =>
                value == null || value.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Mật khẩu"),
                obscureText: true,
                validator: (value) =>
                value == null || value.length < 4 ? "Tối thiểu 4 ký tự" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                value == null || !value.contains('@') ? "Email không hợp lệ" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text("Đăng ký"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
