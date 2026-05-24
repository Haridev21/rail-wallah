// lib/screens/train_search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../providers/train_search_providers.dart';
import 'train_booking_screen.dart';

class TrainSearchScreen extends ConsumerStatefulWidget {
  const TrainSearchScreen({super.key});

  @override
  ConsumerState<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends ConsumerState<TrainSearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    ref.read(trainSearchControllerProvider.notifier).setQuery(_ctrl.text);
    _focusNode.unfocus();
    final info = await ref
        .read(trainSearchControllerProvider.notifier)
        .search();
    if (!mounted || info == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrainBookingScreen(trainInfo: info)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(trainSearchControllerProvider);
    final error = searchState.error;
    final loading = searchState.loading;

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        leading: const BackButton(color: kTextPrimary),
        title: Text(
          'Select Train',
          style: GoogleFonts.sora(
            color: kTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your train number to view seat layout',
                style: GoogleFonts.inter(color: kTextSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Search field
              Container(
                decoration: BoxDecoration(
                  color: kCoachBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: error != null ? kErrorColor : kCoachBorder,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.search_rounded,
                      color: kTextSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                        style: GoogleFonts.sora(
                          color: kTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                        decoration: InputDecoration(
                          hintText: '12951',
                          hintStyle: GoogleFonts.sora(
                            color: kTextSecondary.withValues(alpha: 0.4),
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                        ),
                        onSubmitted: (_) => _search(),
                        onChanged: (value) {
                          ref
                              .read(trainSearchControllerProvider.notifier)
                              .setQuery(value);
                          ref
                              .read(trainSearchControllerProvider.notifier)
                              .clearError();
                        },
                      ),
                    ),
                    if (_ctrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _ctrl.clear();
                          ref
                              .read(trainSearchControllerProvider.notifier)
                              .clearQuery();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.close_rounded,
                            color: kTextSecondary,
                            size: 18,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),

              // Error
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: error != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10, left: 2),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: kErrorColor,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              error,
                              style: GoogleFonts.inter(
                                color: kErrorColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // Search button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: GestureDetector(
                  onTap: loading ? null : _search,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: loading
                            ? [
                                kAccent.withValues(alpha: 0.5),
                                kAccent.withValues(alpha: 0.3),
                              ]
                            : [
                                const Color(0xFF2563EB),
                                const Color(0xFF1D4ED8),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'SEARCH TRAIN',
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Quick picks
              Text(
                'Popular trains',
                style: GoogleFonts.inter(
                  color: kTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['12951', '12301', '12002', '12213', '12354']
                    .map(
                      (no) => GestureDetector(
                        onTap: () {
                          _ctrl.text = no;
                          ref
                              .read(trainSearchControllerProvider.notifier)
                              .setQuery(no);
                          ref
                              .read(trainSearchControllerProvider.notifier)
                              .clearError();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kCoachBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kCoachBorder),
                          ),
                          child: Text(
                            no,
                            style: GoogleFonts.sora(
                              color: kTextSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
