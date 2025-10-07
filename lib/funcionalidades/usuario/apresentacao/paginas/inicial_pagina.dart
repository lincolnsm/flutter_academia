import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../usuario/apresentacao/paginas/cadastro_pagina.dart';
import '../../../usuario/apresentacao/paginas/escolha_nivel_pagina.dart';
import '../../../treino/apresentacao/paginas/treino_pagina.dart';
import '../controladores/login_controlador.dart';

class InicioPagina extends StatefulWidget {
  const InicioPagina({super.key});

  @override
  State<InicioPagina> createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<InicioPagina> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginCtrl = context.watch<LoginControlador>();
    return Scaffold(
      backgroundColor: const Color(0xFF1B2B2A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 180,
                child: Image.asset(
                  "assets/images/logo_principal.png",
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Endereço de email",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.email, color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF7A8F85),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: senhaController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Senha",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF7A8F85),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              loginCtrl.carregando
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final email = emailController.text.trim();
                          final senha = senhaController.text.trim();
                          final sucesso = await loginCtrl.login(
                            email: email,
                            senha: senha,
                          );
                          if (!mounted) return;
                          if (sucesso) {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              final doc = await FirebaseFirestore.instance
                                  .collection('usuarios')
                                  .doc(user.uid)
                                  .get();
                              if (!mounted) return;
                              if (!doc.exists || doc['nivel'] == null) {
                                navigator.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const EscolhaNivelPagina(),
                                  ),
                                );
                              } else {
                                final nivel = doc['nivel'] as String;
                                navigator.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => TreinoPagina(nivel: nivel),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A8F85),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Não tem uma conta? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CadastroPagina(),
                        ),
                      );
                    },
                    child: const Text(
                      "Inscreva-se",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              if (loginCtrl.falha != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    loginCtrl.falha!.mensagem,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}