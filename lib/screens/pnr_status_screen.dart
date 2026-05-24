import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:webview_flutter/webview_flutter.dart';
import '../providers/pnr_providers.dart';

class PnrStatusScreen extends ConsumerStatefulWidget {
  const PnrStatusScreen({super.key});

  @override
  ConsumerState<PnrStatusScreen> createState() => _PnrStatusScreenState();
}

class _PnrStatusScreenState extends ConsumerState<PnrStatusScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            ref.read(pnrPageLoadingProvider.notifier).state = true;
          },
          onPageFinished: (String url) {
            ref.read(pnrPageLoadingProvider.notifier).state = false;
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.confirmtkt.com/pnr-status'));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(pnrPageLoadingProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: WebViewWidget(controller: controller),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A237E)),
            ),
        ],
      ),
    );
  }
}
