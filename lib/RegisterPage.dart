import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('https://localhost/register.php'),
      body: {
        'nome': _nomeController.text,
        'email': _emailController.text,
        'senha': _senhaController.text,
      },
    );

    final data = json.decode(response.body);

    if (data['status'] == 'success') {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF4B000),
        centerTitle: true, 
        title: Text("Registrar",
        style: TextStyle(color: Colors.black,
        fontWeight: FontWeight.bold),)),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
          'assets/logo.png',
          height: 320, // ajuste o tamanho conforme desejar
          ),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text("Registrar",
              style: TextStyle(color: Colors.black,
              
              ),),
            ),
          ],
        ),
      ),
    );
  }
}
