import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:prueba_002/screens/ListaExterna.dart';

class RegistrarScreen extends StatelessWidget {
  const RegistrarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: RegistroFormulario(),
      ),
    );
  }
}

class RegistroFormulario extends StatefulWidget {
  const RegistroFormulario({super.key});

  @override
  _RegistroFormularioState createState() => _RegistroFormularioState();
}

class _RegistroFormularioState extends State<RegistroFormulario> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _registrarUsuario() async {
    String nombre = _nombreController.text.trim();
    String correo = _correoController.text.trim();
    String contrasena = _contrasenaController.text.trim();

    if (nombre.isEmpty || correo.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      return;
    }

    if (contrasena.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La contraseña debe tener al menos 6 caracteres.')),
      );
      return;
    }

    try {
      // Crear usuario en Firebase Authentication
      UserCredential userCredentialResult =
          await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      // Guardar información adicional en Firebase Realtime Database
      DatabaseReference ref = FirebaseDatabase.instance
          .ref("usuarios/${userCredentialResult.user!.uid}");
      await ref.set({
        "nombre": nombre,
        "correo": correo,
      });

      // Mostrar mensaje de éxito y navegar a ListaexternaScreen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListaexternaScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _correoController,
          decoration: const InputDecoration(
            labelText: 'Correo Electrónico',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _contrasenaController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            hintText: 'Debe tener al menos 6 caracteres',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _registrarUsuario,
          child: const Text(
            'Registrarse',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
