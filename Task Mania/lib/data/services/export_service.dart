import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/task_model.dart';
import '../models/subtask_model.dart';

class ExportService {
  Future<String> exportTasksToCsv(List<Task> tasks, Map<int, List<Subtask>> subsMap) async {
    final rows = <List<String>>[
      ['Title', 'Description', 'Priority', 'DueDate', 'Completed', 'Repeat', 'Subtasks']
    ];

    for (final t in tasks) {
      final subs = subsMap[t.id] ?? [];
      final subStr = subs.map((s) => '${s.title}(${s.isDone ? "done" : "pending"})').join('; ');
      rows.add([
        t.title,
        t.description ?? '',
        t.priority,
        t.dueDate?.toIso8601String() ?? '',
        t.isCompleted ? 'Yes' : 'No',
        t.repeatRule ?? '',
        subStr,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tasks_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<void> shareCsv(String path) async => Share.shareXFiles([XFile(path)], text: 'Tasks CSV');

  Future<String> exportTasksToPdf(List<Task> tasks, Map<int, List<Subtask>> subsMap) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (_) => pw.Text('Task Export • ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
            style: pw.TextStyle(color: PdfColors.grey700, fontSize: 11)),
        build: (_) => [
          pw.SizedBox(height: 6),
          ...tasks.map((t) {
            final subs = subsMap[t.id] ?? [];
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(t.title,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: t.isCompleted ? PdfColors.green800 : PdfColors.black)),
                if ((t.description ?? '').isNotEmpty)
                  pw.Text(t.description!, style: const pw.TextStyle(fontSize: 10)),
                pw.Text(
                  'Due: ${t.dueDate != null ? DateFormat('MMM d, h:mm a').format(t.dueDate!) : "N/A"} • Priority: ${t.priority} • Repeat: ${t.repeatRule ?? "—"}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                if (subs.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text('Subtasks:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ...subs.map((s) => pw.Text('- ${s.title} (${s.isDone ? "Done" : "Pending"})', style: const pw.TextStyle(fontSize: 9))),
                ],
                pw.Divider(),
              ],
            );
          }),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tasks_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<void> sharePdf(String path) async => Share.shareXFiles([XFile(path)], text: 'Tasks PDF');
}