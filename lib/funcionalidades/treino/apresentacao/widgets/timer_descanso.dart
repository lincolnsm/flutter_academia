import 'dart:async';
import 'package:flutter/material.dart';

void mostrarTimerDescanso(BuildContext context, {int duracaoSegundos = 60}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (_) => _TimerDescansoSheet(duracaoInicial: duracaoSegundos),
  );
}

class _TimerDescansoSheet extends StatefulWidget {
  final int duracaoInicial;
  const _TimerDescansoSheet({required this.duracaoInicial});

  @override
  State<_TimerDescansoSheet> createState() => _TimerDescansoSheetState();
}

class _TimerDescansoSheetState extends State<_TimerDescansoSheet> {
  late int _total;
  late int _restante;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _total = widget.duracaoInicial;
    _restante = _total;
    _iniciar();
  }

  void _iniciar() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_restante <= 1) {
        t.cancel();
        setState(() => _restante = 0);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        setState(() => _restante--);
      }
    });
  }

  void _trocarDuracao(int nova) {
    _timer?.cancel();
    setState(() {
      _total = nova;
      _restante = nova;
    });
    _iniciar();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progresso = _total > 0 ? _restante / _total : 0.0;
    final int min = _restante ~/ 60;
    final int seg = _restante % 60;
    final String tempo =
        '${min.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}';
    final bool quaseAcabando = _restante <= 10 && _restante > 0;
    final bool concluido = _restante == 0;

    return Container(
      padding: const EdgeInsets.only(bottom: 32),
      decoration: const BoxDecoration(
        color: Color(0xFF1B2B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'DESCANSO',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: 190,
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progresso,
                      strokeWidth: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.07),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        concluido
                            ? const Color(0xFFA8D5BA)
                            : quaseAcabando
                                ? Colors.redAccent
                                : const Color(0xFFA8D5BA),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          concluido ? 'Pronto!' : tempo,
                          key: ValueKey(concluido),
                          style: TextStyle(
                            color: concluido
                                ? const Color(0xFFA8D5BA)
                                : Colors.white,
                            fontSize: concluido ? 28 : 46,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!concluido)
                        const Text(
                          'restante',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Alterar duração',
              style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [30, 60, 90, 120, 180].map((s) {
                final bool sel = _total == s;
                final label = s < 60
                    ? '${s}s'
                    : s % 60 == 0
                        ? '${s ~/ 60}min'
                        : '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
                return GestureDetector(
                  onTap: () => _trocarDuracao(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFA8D5BA)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: sel
                            ? const Color(0xFF1B2B2A)
                            : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _trocarDuracao(_total),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reiniciar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8D5BA),
                    foregroundColor: const Color(0xFF1B2B2A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: const Text('Pular',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
