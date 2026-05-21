import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _angka1Controller = TextEditingController();
  final TextEditingController _angka2Controller = TextEditingController();
  final FocusNode _focus1 = FocusNode();
  final FocusNode _focus2 = FocusNode();

  String _hasil = '';
  String _operasiDipilih = '';
  bool _adaError = false;
  bool _showExpression = false;
  late AnimationController _resultAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _resultAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _resultAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _resultAnim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _angka1Controller.dispose();
    _angka2Controller.dispose();
    _focus1.dispose();
    _focus2.dispose();
    _resultAnim.dispose();
    super.dispose();
  }

  void _pilihOperasi(String operasi) {
    if (_angka1Controller.text.isEmpty) {
      _showSnack('Masukkan angka pertama terlebih dahulu');
      return;
    }
    setState(() {
      _operasiDipilih = operasi;
      _adaError = false;
      _hasil = '';
      _showExpression = false;
    });
    FocusScope.of(context as BuildContext? ?? context).requestFocus(_focus2);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context as BuildContext? ?? context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _hitung() {
    FocusScope.of(context as BuildContext? ?? context).unfocus();

    if (_angka1Controller.text.isEmpty) {
      setState(() {
        _adaError = true;
        _hasil = 'Angka pertama tidak boleh kosong';
        _showExpression = false;
      });
      _resultAnim.forward(from: 0);
      return;
    }

    if (_angka2Controller.text.isEmpty) {
      setState(() {
        _adaError = true;
        _hasil = 'Angka kedua tidak boleh kosong';
        _showExpression = false;
      });
      _resultAnim.forward(from: 0);
      return;
    }

    if (_operasiDipilih.isEmpty) {
      setState(() {
        _adaError = true;
        _hasil = 'Pilih operasi terlebih dahulu';
        _showExpression = false;
      });
      _resultAnim.forward(from: 0);
      return;
    }

    final double? a = double.tryParse(_angka1Controller.text);
    final double? b = double.tryParse(_angka2Controller.text);

    if (a == null || b == null) {
      setState(() {
        _adaError = true;
        _hasil = 'Masukkan angka yang valid';
        _showExpression = false;
      });
      _resultAnim.forward(from: 0);
      return;
    }

    if (_operasiDipilih == '÷' && b == 0) {
      setState(() {
        _adaError = true;
        _hasil = 'Tidak bisa dibagi dengan nol';
        _showExpression = false;
      });
      _resultAnim.forward(from: 0);
      return;
    }

    double hasil;
    switch (_operasiDipilih) {
      case '+':
        hasil = a + b;
        break;
      case '−':
        hasil = a - b;
        break;
      case '×':
        hasil = a * b;
        break;
      case '÷':
        hasil = a / b;
        break;
      default:
        return;
    }

    final String hasilStr = hasil == hasil.truncateToDouble()
        ? hasil.toInt().toString()
        : hasil.toStringAsFixed(4);

    setState(() {
      _adaError = false;
      _hasil = hasilStr;
      _showExpression = true;
    });
    _resultAnim.forward(from: 0);
  }

  void _reset() {
    _resultAnim.reverse();
    setState(() {
      _angka1Controller.clear();
      _angka2Controller.clear();
      _hasil = '';
      _operasiDipilih = '';
      _adaError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Kalkulator',
          style: GoogleFonts.dmSerifDisplay(
            color: const Color(0xFF1A1A2E),
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded),
              color: const Color(0xFF9999BB),
              tooltip: 'Reset',
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel(label: 'Masukkan Angka'),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _CalcTextField(
                      controller: _angka1Controller,
                      focusNode: _focus1,
                      label: 'Angka Pertama',
                      hint: '0',
                      isFirst: true,
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F8)),
                    _CalcTextField(
                      controller: _angka2Controller,
                      focusNode: _focus2,
                      label: 'Angka Kedua',
                      hint: '0',
                      isFirst: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const _SectionLabel(label: 'Operasi'),
              const SizedBox(height: 12),

              Row(
                children: [
                  _OpButton(
                    simbol: '+',
                    label: 'Tambah',
                    dipilih: _operasiDipilih == '+',
                    accentColor: const Color(0xFF10B981),
                    onTap: () => _pilihOperasi('+'),
                  ),
                  const SizedBox(width: 10),
                  _OpButton(
                    simbol: '−',
                    label: 'Kurang',
                    dipilih: _operasiDipilih == '−',
                    accentColor: const Color(0xFFEF4444),
                    onTap: () => _pilihOperasi('−'),
                  ),
                  const SizedBox(width: 10),
                  _OpButton(
                    simbol: '×',
                    label: 'Kali',
                    dipilih: _operasiDipilih == '×',
                    accentColor: const Color(0xFF0EA5E9),
                    onTap: () => _pilihOperasi('×'),
                  ),
                  const SizedBox(width: 10),
                  _OpButton(
                    simbol: '÷',
                    label: 'Bagi',
                    dipilih: _operasiDipilih == '÷',
                    accentColor: const Color(0xFFD4AF37),
                    onTap: () => _pilihOperasi('÷'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _adaError
                      ? const Color(0xFFFFF5F5)
                      : _hasil.isNotEmpty
                          ? const Color(0xFF1A1A2E)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _hasil.isNotEmpty && !_adaError
                          ? const Color(0xFF1A1A2E).withValues(alpha: 0.25)
                          : const Color(0xFF1A1A2E).withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _hasil.isEmpty
                    ? const Row(
                        children: [
                          Icon(
                            Icons.functions_rounded,
                            color: Color(0xFFCCCCDD),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Hasil akan muncul di sini',
                            style: TextStyle(
                              color: Color(0xFFCCCCDD),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    : FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: _adaError
                              ? Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        color: Color(0xFFEF4444), size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _hasil,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFEF4444),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HASIL',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(alpha: 0.4),
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _hasil,
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 42,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    if (_showExpression &&
                                        _angka1Controller.text.isNotEmpty &&
                                        _angka2Controller.text.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${_angka1Controller.text}  $_operasiDipilih  ${_angka2Controller.text}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                Colors.white.withValues(alpha: 0.4),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // ── Calculate Button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hitung,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Hitung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _reset,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF9999BB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9999BB),
        letterSpacing: 2,
      ),
    );
  }
}

class _CalcTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final bool isFirst;

  const _CalcTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Color(0xFF9999BB),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(color: Color(0xFFDDDDEE), fontSize: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          prefixIcon: Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              isFirst ? 'A' : 'B',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFCCCCDD),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpButton extends StatelessWidget {
  final String simbol;
  final String label;
  final bool dipilih;
  final Color accentColor;
  final VoidCallback onTap;

  const _OpButton({
    required this.simbol,
    required this.label,
    required this.dipilih,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: dipilih ? accentColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: dipilih
                    ? accentColor.withValues(alpha: 0.3)
                    : const Color(0xFF1A1A2E).withValues(alpha: 0.05),
                blurRadius: dipilih ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                simbol,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: dipilih ? Colors.white : accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: dipilih
                      ? Colors.white.withValues(alpha: 0.85)
                      : const Color(0xFFAAAABC),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}