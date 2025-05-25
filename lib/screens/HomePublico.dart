import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePublico extends StatelessWidget {
  final List<String> imagePaths = [
    'assets/banner0.png',
    'assets/banner3.png',
    'assets/bier0.png',
    'asseets/sagres.png',
    'assets/bier3.png',
    'assets/logo.png',
  ];

  final Color primaryColor = const Color(0xFFF4B000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Pública'),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Slider de Imagens
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                initialPage: 30,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                aspectRatio: 16 / 9,
              ),
              items: imagePaths.map((path) {
                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // Botões de Navegação
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildNavButton(
                    context,
                    icon: Icons.add_box,
                    label: 'Adicionar Produto',
                    routeName: '/adicionarProduto',
                  ),
                  _buildNavButton(
                    context,
                    icon: Icons.bar_chart,
                    label: 'Relatório de Vendas',
                    routeName: '/relatorioVendas',
                  ),
                  _buildNavButton(
                    context,
                    icon: Icons.attach_money,
                    label: 'Vendas do Dia',
                    routeName: '/vendasdodia',
                  ),
                  _buildNavButton(
                    context,
                    icon: Icons.person_add,
                    label: 'Criar Conta',
                    routeName: '/register',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context,
      {required IconData icon,
      required String label,
      required String routeName}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 24,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, routeName),
        icon: Icon(icon),
        label: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
