import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../core/constants.dart';
import '../../core/logger/logger.dart';
import '../widgets/rootcastle_app_bar.dart';

/// Tanılama (Diagnostics) sayfası — logları gör, paylaş.
class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  List<String> _logLines = [];
  bool _loading = true;
  bool _maskPii = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    try {
      final lines = await AppLogger.instance.getRecentLines(kLogUiLineCount);
      setState(() {
        _logLines = lines;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _logLines = ['Log yüklenirken hata: $e'];
        _loading = false;
      });
    }
  }

  Future<void> _shareLogs() async {
    try {
      final logContent = await AppLogger.instance.getAllLogs();
      final dir = await getApplicationDocumentsDirectory();
      final exportPath = p.join(dir.path, 'seker_takip_logs.txt');
      await File(exportPath).writeAsString(logContent);
      await Share.shareXFiles([XFile(exportPath)]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Tr.hata}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RootcastleAppBar(
        title: Tr.tanilamaLoglari,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadLogs,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: Tr.loglariPaylas,
            onPressed: _shareLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // PII Maskeleme toggle
          SwitchListTile(
            title: const Text(Tr.piiMaskele),
            value: _maskPii,
            onChanged: (v) {
              setState(() => _maskPii = v);
              AppLogger.instance.maskPiiEnabled = v;
            },
          ),
          const Divider(height: 1),
          // Log satırları
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _logLines.isEmpty
                ? const Center(child: Text('Henüz log kaydı yok.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _logLines.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          _logLines[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
