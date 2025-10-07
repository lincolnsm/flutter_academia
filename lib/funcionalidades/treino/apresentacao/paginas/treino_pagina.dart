import 'package:flutter/material.dart';
import '../../dominio/entidades/treino.dart';
import '../../dominio/entidades/exercicios.dart';
import '../../dados/repositorios/exercicios_data.dart';
import '../../../usuario/widgets/painel_usuario.dart';

class TreinoPagina extends StatelessWidget {
  final String nivel;
  const TreinoPagina({super.key, required this.nivel});

  List<Treino> _gerarTreinos() {
    final Map<String, int> quantidadePorNivel = {
      "iniciante": 3,
      "intermediario": 4,
      "avancado": 5,
    };

    final nivelNormalizado = nivel.trim().toLowerCase();
    final int quantidade = quantidadePorNivel[nivelNormalizado] ?? 3;
    final configuracoes = [
      {"titulo": "Treino A", "tag": "treinoA"},
      {"titulo": "Treino B", "tag": "treinoB"},
      {"titulo": "Treino C", "tag": "treinoC"},
      {"titulo": "Treino D", "tag": "treinoD"},
      {"titulo": "Treino E", "tag": "treinoE"},
    ];

    final treinos = <Treino>[];
    for (var i = 0; i < quantidade; i++) {
      final conf = configuracoes[i];
      final tagConf = (conf['tag'] ?? '').toString().toLowerCase();
      final exerciciosDoTreino = exercicios.where((ex) {
        final tagsLower = ex.tags.map((t) => t.toLowerCase()).toList();
        return tagsLower.contains(tagConf) && tagsLower.contains(nivelNormalizado);
      }).toList();
      final seen = <String>{};
      final listaSemDuplicados = <Exercicio>[];
      for (final ex in exerciciosDoTreino) {
        final key = "${ex.nome.trim().toLowerCase()}_${ex.imagem}";
        if (!seen.contains(key)) {
          seen.add(key);
          listaSemDuplicados.add(ex);
        }
      }

      treinos.add(
        Treino(
          titulo: conf['titulo'] as String,
          botaoEscuro: i.isEven,
          exercicios: listaSemDuplicados,
        ),
      );
    }
    return treinos;
  }

  @override
  Widget build(BuildContext context) {
    final treinos = _gerarTreinos();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2B2A),
        elevation: 0,
        title: Text("Nível ${nivel[0].toUpperCase()}${nivel.substring(1)}"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: treinos.length,
        itemBuilder: (context, index) {
          final treino = treinos[index];
          return _CardTreino(
            treino: treino,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/treino/exercicios',
                arguments: treino,
              );
            },
          );
        },
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

class _CardTreino extends StatelessWidget {
  final Treino treino;
  final VoidCallback onPressed;
  const _CardTreino({required this.treino, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3E5953),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFF2E3D3C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.fitness_center,
                size: 40,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                treino.titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    treino.botaoEscuro ? const Color(0xFF1B2B2A) : Colors.white,
                foregroundColor:
                    treino.botaoEscuro ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onPressed,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Iniciar"),
            ),
          ),
        ],
      ),
    );
  }
}