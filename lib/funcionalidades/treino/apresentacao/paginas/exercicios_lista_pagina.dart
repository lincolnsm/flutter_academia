import 'package:flutter/material.dart';
import '../../dominio/entidades/exercicios.dart';
import '../../dados/repositorios/exercicios_data.dart';
import '../../../usuario/widgets/painel_usuario.dart';

class ExerciciosListaPagina extends StatefulWidget {
  final String tipo;
  final List<Exercicio>? exercicios;
  const ExerciciosListaPagina({
    super.key,
    required this.tipo,
    this.exercicios,
  });

  @override
  State<ExerciciosListaPagina> createState() => _ExerciciosListaPageState();
}

class _ExerciciosListaPageState extends State<ExerciciosListaPagina> {
  late String selectedTipo;

  @override
  void initState() {
    super.initState();
    selectedTipo = "academia";
  }

  Widget _categoriaBotao(String label, String tipoValor, String? assetImagem) {
    final bool ativo = selectedTipo == tipoValor;
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: ativo
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: ativo ? Border.all(color: Colors.white24) : null,
      ),
      child: Column(
        children: [
          if (assetImagem != null && assetImagem.isNotEmpty)
            SizedBox(
              height: 56,
              child: Image.asset(assetImagem, fit: BoxFit.contain),
            ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ativo ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)!.settings.arguments;
    String nivel = "";
    String treino = "";
    if (routeArgs is Map) {
      nivel = (routeArgs['nivel'] ?? '').toString().toLowerCase();
      treino = (routeArgs['treino'] ?? '').toString().toLowerCase();
    }
    final listaBase = widget.exercicios ??
        exercicios.where((e) {
          final tagsLower = e.tags.map((t) => t.toLowerCase()).toList();
          return e.tipoEquipamento.toLowerCase() == selectedTipo &&
              (nivel.isEmpty || tagsLower.contains(nivel)) &&
              (treino.isEmpty || tagsLower.contains(treino));
        }).toList();
    final seen = <String>{};
    final listaSemDuplicados = <Exercicio>[];
    for (final ex in listaBase) {
      final key = "${ex.nome.trim().toLowerCase()}_${ex.imagem}";
        if (!seen.contains(key)) {
          seen.add(key);
          listaSemDuplicados.add(ex);
        }
    }
    final lista10 = listaSemDuplicados.take(10).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1B2B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2B2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Exercícios",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Treino na Academia",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Center(
                child: _categoriaBotao(
                  "Academia",
                  "academia",
                  "assets/images/academia_logo.png",
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: lista10.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum exercício disponível para academia.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: lista10.length,
                      itemBuilder: (context, index) {
                        final Exercicio ex = lista10[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.nome,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B2B2A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  ex.imagem,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: ex.linkYoutube != null
                                      ? () {
                                          Navigator.pushNamed(
                                            context,
                                            '/treino/video',
                                            arguments: {
                                              'titulo': ex.nome,
                                              'urlVideo': ex.linkYoutube,
                                              'imagem': ex.imagem,
                                            },
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B2B2A),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.play_arrow,
                                      color: Colors.white),
                                  label: const Text(
                                    "Assistir treino",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: const Color(0xFF2E3D3C),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              onTap: () => PainelUsuario.abrir(context),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.person,
                  color: Colors.white70,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}