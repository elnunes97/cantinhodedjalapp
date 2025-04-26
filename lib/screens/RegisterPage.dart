import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _tipoSelecionado = 'usuario';

  bool _mostrarAnimacao = false;
  String _mensagem = '';
  bool _sucesso = false;

  Future<void> _register() async {
    setState(() {
      _mostrarAnimacao = false;
      _mensagem = '';
    });

    final response = await http.post(
      Uri.parse('http://localhost/register.php'),
      body: {
        'nome': _nomeController.text,
        'email': _emailController.text,
        'senha': _senhaController.text,
        'tipo': _tipoSelecionado,
      },
    );

    final data = json.decode(response.body);

    setState(() {
      _sucesso = data['status'] == 'success';
      _mensagem = data['message'];
      _mostrarAnimacao = true;

      if (_sucesso) {
        _nomeController.clear();
        _emailController.clear();
        _senhaController.clear();
        _tipoSelecionado = 'usuario';
      }
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() => _mostrarAnimacao = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF4B000),
        centerTitle: true,
        title: Text(
          "Registrar",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo no topo
            Image.asset(
              'assets/logo.png',
              height: screenHeight * 0.2,
            ),

            // Animação de feedback
            if (_mostrarAnimacao)
              Column(
                children: [
                  Lottie.asset(
                    _sucesso ? 'assets/register.json' : 'assets/error.json',
                    height: 150,
                    repeat: false,
                  ),
                  Text(
                    _mensagem,
                    style: TextStyle(
                      color: _sucesso ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),

            // Campo de Nome
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: "Nome",
                prefixIcon: Icon(Icons.person, color: Color(0xFFF4B000)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFF4B000)),
                ),
              ),
            ),
            SizedBox(height: 15),

            // Campo de Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email, color: Color(0xFFF4B000)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFF4B000)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),

            // Campo de Senha
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                prefixIcon: Icon(Icons.lock, color: Color(0xFFF4B000)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFF4B000)),
                ),
              ),
            ),
            SizedBox(height: 15),

            // Dropdown de Tipo de Usuário
            DropdownButtonFormField<String>(
              value: _tipoSelecionado,
              decoration: InputDecoration(
                labelText: "Tipo de usuário",
                prefixIcon: Icon(Icons.admin_panel_settings, color: Color(0xFFF4B000)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFF4B000)),
                ),
              ),
              items: ['admin', 'usuario'].map((tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(
                    tipo[0].toUpperCase() + tipo.substring(1),
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  _tipoSelecionado = valor!;
                });
              },
            ),
            SizedBox(height: 25),

            // Botão de Registro
            ElevatedButton.icon(
              onPressed: _register,
              icon: Icon(Icons.check, color: Colors.black),
              label: Text(
                "Registrar",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF4B000),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}