import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../treino/apresentacao/paginas/treino_pagina.dart';

class EscolhaNivelPagina extends StatefulWidget {
  const EscolhaNivelPagina({super.key});

  @override
  State<EscolhaNivelPagina> createState() => _EscolhaNivelPaginaState();
}

class _EscolhaNivelPaginaState extends State<EscolhaNivelPagina> {
  Future<void> salvarNivel(String nivel) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef =
          FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      await docRef.set({'nivel': nivel}, SetOptions(merge: true));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TreinoPagina(nivel: nivel),
        ),
      );
    }
  }

  Widget _buildCard({
    required String titulo,
    required String descricao,
    required String imagem,
    required Color cor,
    required String nivel,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descricao,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => salvarNivel(nivel),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Começar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 1,
            child: Image.asset(
              imagem,
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2B2A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              titulo: "Iniciante",
              descricao: "Nunca treinei ou estou começando agora.",
              imagem: "assets/images/treino_iniciante.png",
              cor: const Color(0xFFA8D5BA),
              nivel: "iniciante",
            ),
            _buildCard(
              titulo: "Intermediário",
              descricao: "Já treino há 1 ano de forma regular.",
              imagem: "assets/images/treino_intermediario.png",
              cor: const Color(0xFFF4EFEA),
              nivel: "intermediario",
            ),
            _buildCard(
              titulo: "Avançado",
              descricao: "Treino há mais de 2 anos de forma consistente.",
              imagem: "assets/images/treino_avancado.png",
              cor: const Color(0xFF7A8F85),
              nivel: "avancado",
            ),
          ],
        ),
      ),
    );
  }
}
