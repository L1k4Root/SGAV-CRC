import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../users/data/user_repository.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  double _pwdStrength = 0.0;
  bool _obscurePwd = true;
  XFile? _avatarFile;
  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();

  void _calcPwdStrength(String pwd) {
    setState(() {
      _pwdStrength = (pwd.length / 20).clamp(0, 1);
    });
  }

  String _firebaseErrMsg(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este email ya está registrado.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'weak-password':
        return 'Contraseña muy débil.';
      default:
        return 'Ocurrió un error. Intente nuevamente.';
    }
  }

  void _quickSnack(String msg) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final img =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (img != null) {
      if (kIsWeb) {
        final bytes = await img.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
          _avatarFile = img;
        });
      } else {
        setState(() => _avatarFile = img);
      }
    }
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

      // Ensure avatar bytes are available for both web and mobile
      Uint8List? avatarData = _avatarBytes;
      if (avatarData == null && _avatarFile != null) {
        avatarData = await _avatarFile!.readAsBytes();
      }

      // Encode avatar as Base64 for Firestore
      String? avatarBase64;
      if (avatarData != null) {
        avatarBase64 = base64Encode(avatarData);
      }

    try {
      final repo = UserRepository();
      await repo.registerNewUser(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text.trim(),
        role: _selectedRole,
        block: false,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        avatarBase64: avatarBase64,
      );
      if (mounted) {
        _quickSnack('Usuario creado correctamente');
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _quickSnack(_firebaseErrMsg(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _autoFillRole(String role) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    String prefix;
    switch (role) {
      case 'guard':
        prefix = 'guardia';
        break;
      case 'admin':
        prefix = 'admin';
        break;
      default:
        prefix = 'residente';
    }
    final username = '$prefix$ts';
    final email = '$username@example.com';
    const password = 'QWERTY123'; // default predictable password

    setState(() {
      _nameCtrl.text = '${prefix[0].toUpperCase()}${prefix.substring(1)} $ts';
      _emailCtrl.text = email;
      _pwdCtrl.text = password;
      _phoneCtrl.text = '';
      _selectedRole = role;
      _calcPwdStrength(password);
    });

    _quickSnack('Autocompletado $role: $email');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _selectedRole = 'resident';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _avatarBytes != null
                        ? MemoryImage(_avatarBytes!)
                        : _avatarFile != null
                            ? FileImage(File(_avatarFile!.path))
                            : null,
                    child: _avatarFile == null
                        ? const Icon(Icons.camera_alt, size: 32)
                        : null,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Auto Residente'),
                    onPressed: () => _autoFillRole('resident'),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Auto Guardia'),
                    onPressed: () => _autoFillRole('guard'),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Auto Admin'),
                    onPressed: () => _autoFillRole('admin'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.trim().length < 3) ? 'Ingrese su nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || !val.contains('@')) ? 'Email inválido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pwdCtrl,
                obscureText: _obscurePwd,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePwd ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                  ),
                ),
                validator: (val) =>
                    (val == null || val.length < 6) ? 'Mínimo 6 caracteres' : null,
                onChanged: _calcPwdStrength,
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: _pwdStrength,
                minHeight: 4,
                backgroundColor: Colors.grey.shade300,
                color: _pwdStrength < 0.3
                    ? Colors.red
                    : _pwdStrength < 0.7
                        ? Colors.orange
                        : Colors.green,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'resident', child: Text('Residente')),
                  DropdownMenuItem(value: 'guard', child: Text('Guardia')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_loading ? 'Creando...' : 'Crear usuario'),
                onPressed: _loading ? null : _createUser,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
