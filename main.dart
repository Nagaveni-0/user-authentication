// main.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      home: const LoginScreen(),
    );
  }
}

/// -------------------- LOGIN SCREEN --------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String? error;

  void login() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await ApiService.login(
        usernameController.text.trim(),
        passwordController.text,
      );

      final token = result['token'];
      final user = result['user'];

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(token: token, user: user),
        ),
      );
    } catch (e) {
      setState(() {
        error = 'Login failed. Check your username/password.';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- REGISTER SCREEN --------------------
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String? error;

  void register() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await ApiService.register(
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );

      final token = result['token'];
      final user = result['user'];

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(token: token, user: user),
        ),
      );
    } catch (e) {
      setState(() {
        error = 'Registration failed. Try a different username.';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : register,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- PROFILE SCREEN --------------------
class ProfileScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  const ProfileScreen({super.key, required this.token, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> user;
  bool loading = false;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = widget.user;
    firstNameController.text = user['first_name'] ?? '';
    lastNameController.text = user['last_name'] ?? '';
    refreshProfile();
  }

  void refreshProfile() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.getProfile(widget.token);
      setState(() {
        user = data;
        firstNameController.text = user['first_name'] ?? '';
        lastNameController.text = user['last_name'] ?? '';
      });
    } catch (_) {
      // ignore refresh errors, keep showing existing data
    } finally {
      setState(() => loading = false);
    }
  }

  void saveProfile() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.updateProfile(widget.token, {
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
      });
      setState(() => user = data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: ${user['username'] ?? ''}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('Email: ${user['email'] ?? ''}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveProfile,
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}