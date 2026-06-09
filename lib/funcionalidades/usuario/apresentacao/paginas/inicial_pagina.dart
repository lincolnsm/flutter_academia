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
  State<InicioPagina> createState() => _InicioPaginaState();
}

class _InicioPaginaState extends State<InicioPagina> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginCtrl = context.watch<LoginControlador>();

    return Scaffold(
      backgroundColor: const Color(0xFF1B2B2A),
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3E5953).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E3D3C).withValues(alpha: 0.5),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        height: 90,
                        width: 90,
                        child: Image.asset(
                          'assets/images/logo_principal.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.fitness_center,
                            color: Color(0xFFA8D5BA),
                            size: 52,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Bem-vindo de volta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Entre para continuar seu treino',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    // Email field
                    _CampoTexto(
                      controller: _emailCtrl,
                      hint: 'E-mail',
                      icone: Icons.email_outlined,
                      teclado: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    // Password field
                    _CampoTexto(
                      controller: _senhaCtrl,
                      hint: 'Senha',
                      icone: Icons.lock_outline,
                      obscuro: !_senhaVisivel,
                      sufixo: IconButton(
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white38,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _senhaVisivel = !_senhaVisivel),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Login button
                    loginCtrl.carregando
                        ? const SizedBox(
                            height: 52,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFA8D5BA),
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () => _entrar(context, loginCtrl),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA8D5BA),
                                foregroundColor: const Color(0xFF1B2B2A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'ENTRAR',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                    if (loginCtrl.falha != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  loginCtrl.falha!.mensagem,
                                  style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    // Divider
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: Colors.white.withValues(alpha: 0.1))),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('ou',
                              style: TextStyle(
                                  color: Colors.white24, fontSize: 13)),
                        ),
                        Expanded(
                            child: Divider(
                                color: Colors.white.withValues(alpha: 0.1))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não tem uma conta? ',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CadastroPagina()),
                          ),
                          child: const Text(
                            'Criar conta',
                            style: TextStyle(
                              color: Color(0xFFA8D5BA),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _entrar(
      BuildContext context, LoginControlador loginCtrl) async {
    final navigator = Navigator.of(context);
    final sucesso = await loginCtrl.login(
      email: _emailCtrl.text.trim(),
      senha: _senhaCtrl.text.trim(),
    );
    if (!mounted) return;
    if (!sucesso) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    if (!mounted) return;

    if (!doc.exists || doc['nivel'] == null) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const EscolhaNivelPagina()),
      );
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(
            builder: (_) => TreinoPagina(nivel: doc['nivel'] as String)),
      );
    }
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icone;
  final bool obscuro;
  final TextInputType teclado;
  final Widget? sufixo;

  const _CampoTexto({
    required this.controller,
    required this.hint,
    required this.icone,
    this.obscuro = false,
    this.teclado = TextInputType.text,
    this.sufixo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscuro,
        keyboardType: teclado,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icone, color: Colors.white38, size: 20),
          suffixIcon: sufixo,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}
