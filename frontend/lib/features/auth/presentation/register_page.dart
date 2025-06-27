import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pwd.text.trim(),
      );

      // Doc inicial en Firestore con rol residente inactivo
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'fullName': _name.text.trim(),
        'email': _email.text.trim(),
        'role': 'resident',
        'inactive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await cred.user!.sendEmailVerification();
      if (!mounted) return;
      Navigator.pop(context); // vuelve al login con mensaje
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Revisa tu correo para verificar tu cuenta'),
        duration: Duration(seconds: 2),
      ));
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.code == 'email-already-in-use'
          ? 'El correo ya está registrado'
          : e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pwd.dispose();
    _pwd2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nombre completo'),
                    validator: (v) =>
                        v == null || v.trim().length < 3 ? 'Ingrese su nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (v) {
                      final reg = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      return v == null || !reg.hasMatch(v) ? 'Correo inválido' : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pwd,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pwd2,
                    obscureText: _obscure,
                    decoration: const InputDecoration(labelText: 'Repetir contraseña'),
                    validator: (v) =>
                        v != _pwd.text ? 'Las contraseñas no coinciden' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _createAccount,
                          child: const Text('Crear cuenta'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
