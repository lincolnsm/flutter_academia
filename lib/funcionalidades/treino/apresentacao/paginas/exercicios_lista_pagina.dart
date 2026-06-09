import 'package:flutter/material.dart';
import '../../dominio/entidades/exercicios.dart';
import '../../dados/repositorios/exercicios_data.dart';
import '../../../usuario/widgets/painel_usuario.dart';
import '../widgets/timer_descanso.dart';

class ExerciciosListaPagina extends StatefulWidget {
  final String tipo;
  final List<Exercicio>? exercicios;
  const ExerciciosListaPagina({
    super.key,
    required this.tipo,
    this.exercicios,
  });

  @override
  State<ExerciciosListaPagina> createState() => _ExerciciosListaPaginaState();
}

int _parseSeries(String reps) {
  final m = RegExp(r'^\s*(\d+)').firstMatch(reps);
  if (m != null) {
    final n = int.tryParse(m.group(1)!);
    if (n != null && n >= 2 && n <= 6) return n;
  }
  return 3;
}

class _ExerciciosListaPaginaState extends State<ExerciciosListaPagina> {
  final Map<int, int> _seriesFeitas = {};

  List<Exercicio> _buildLista() {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    String nivel = '';
    String treino = '';
    if (routeArgs is Map) {
      nivel = (routeArgs['nivel'] ?? '').toString().toLowerCase();
      treino = (routeArgs['treino'] ?? '').toString().toLowerCase();
    }

    final listaBase = widget.exercicios ??
        exercicios.where((e) {
          final tagsLower = e.tags.map((t) => t.toLowerCase()).toList();
          return (nivel.isEmpty || tagsLower.contains(nivel)) &&
              (treino.isEmpty || tagsLower.contains(treino));
        }).toList();

    final seen = <String>{};
    final lista = <Exercicio>[];
    for (final ex in listaBase) {
      final key = '${ex.nome.trim().toLowerCase()}_${ex.imagem}';
      if (seen.add(key)) lista.add(ex);
    }
    return lista.take(8).toList();
  }

  void _concluirSerie(int index, int totalSeries) {
    final atual = _seriesFeitas[index] ?? 0;
    if (atual < totalSeries) {
      setState(() => _seriesFeitas[index] = atual + 1);
      mostrarTimerDescanso(context, duracaoSegundos: 60);
    }
  }

  void _resetarSeries(int index) {
    setState(() => _seriesFeitas.remove(index));
  }

  @override
  Widget build(BuildContext context) {
    final lista = _buildLista();

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
          'Exercícios',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${lista.length} exerc.',
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: lista.isEmpty
          ? const Center(
              child: Text(
                'Nenhum exercício disponível.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final ex = lista[index];
                final total = _parseSeries(ex.reps);
                final feitas = _seriesFeitas[index] ?? 0;
                final concluido = feitas >= total;
                return _CardExercicio(
                  exercicio: ex,
                  index: index,
                  seriesFeitas: feitas,
                  totalSeries: total,
                  concluido: concluido,
                  onConcluirSerie: () => _concluirSerie(index, total),
                  onReset: () => _resetarSeries(index),
                  onVerVideo: ex.linkYoutube != null
                      ? () => Navigator.pushNamed(
                            context,
                            '/treino/video',
                            arguments: {
                              'titulo': ex.nome,
                              'urlVideo': ex.linkYoutube,
                              'imagem': ex.imagem,
                              'reps': ex.reps,
                              'descricao': ex.descricao,
                            },
                          )
                      : null,
                );
              },
            ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Color(0xFF2E3D3C),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              splashColor: Colors.white24,
              onTap: () => PainelUsuario.abrir(context),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.person, color: Colors.white54, size: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardExercicio extends StatelessWidget {
  final Exercicio exercicio;
  final int index;
  final int seriesFeitas;
  final int totalSeries;
  final bool concluido;
  final VoidCallback onConcluirSerie;
  final VoidCallback onReset;
  final VoidCallback? onVerVideo;

  const _CardExercicio({
    required this.exercicio,
    required this.index,
    required this.seriesFeitas,
    required this.totalSeries,
    required this.concluido,
    required this.onConcluirSerie,
    required this.onReset,
    required this.onVerVideo,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: concluido
            ? const Color(0xFF243B32)
            : const Color(0xFF2E3D3C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: concluido
              ? const Color(0xFFA8D5BA).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.asset(
                  exercicio.imagem,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 170,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: const Center(
                      child: Icon(Icons.fitness_center,
                          color: Colors.white24, size: 40),
                    ),
                  ),
                ),
                if (concluido)
                  Container(
                    height: 170,
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.45),
                    child: const Center(
                      child: Icon(Icons.check_circle,
                          color: Color(0xFFA8D5BA), size: 52),
                    ),
                  ),
                // Number badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercicio.nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (concluido)
                      GestureDetector(
                        onTap: onReset,
                        child: const Text(
                          'Refazer',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white38),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // Reps badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA8D5BA).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.repeat,
                              size: 12, color: Color(0xFFA8D5BA)),
                          const SizedBox(width: 4),
                          Text(
                            exercicio.reps,
                            style: const TextStyle(
                              color: Color(0xFFA8D5BA),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Series progress
                Row(
                  children: [
                    const Text(
                      'Séries:',
                      style:
                          TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(width: 10),
                    ...List.generate(totalSeries, (i) {
                      final done = i < seriesFeitas;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? const Color(0xFFA8D5BA)
                              : Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: done
                                ? Colors.transparent
                                : Colors.white24,
                          ),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check,
                                  size: 14, color: Color(0xFF1B2B2A))
                              : Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 14),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: concluido ? null : onConcluirSerie,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: concluido
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFA8D5BA),
                          disabledBackgroundColor:
                              Colors.white.withValues(alpha: 0.06),
                          foregroundColor: const Color(0xFF1B2B2A),
                          disabledForegroundColor: Colors.white24,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        icon: Icon(
                          concluido
                              ? Icons.check_circle_outline
                              : Icons.timer_outlined,
                          size: 18,
                        ),
                        label: Text(
                          concluido
                              ? 'Concluído'
                              : seriesFeitas == 0
                                  ? 'Iniciar Série'
                                  : 'Série ${seriesFeitas + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    if (onVerVideo != null) ...[
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 44,
                        width: 44,
                        child: OutlinedButton(
                          onPressed: onVerVideo,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.play_arrow,
                              color: Colors.white54, size: 22),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
