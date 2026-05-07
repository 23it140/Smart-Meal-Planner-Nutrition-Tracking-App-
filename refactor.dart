import 'dart:io';

void main() {
  final directory = Directory('lib');
  final files = directory.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('app_theme.dart')) continue;

    String content = file.readAsStringSync();

    // Remove const from widgets that will use dynamic colors
    content = content.replaceAll('const TextStyle(', 'TextStyle(');
    content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
    content = content.replaceAll('const Icon(', 'Icon(');
    content = content.replaceAll('const Divider(', 'Divider(');
    content = content.replaceAll('const BorderSide(', 'BorderSide(');
    content = content.replaceAll('const ColorScheme.dark(', 'ColorScheme.dark(');

    // Replace color constants with context-based getters
    content = content.replaceAll('AppTheme.bgDark', 'AppTheme.bgDark(context)');
    content = content.replaceAll('AppTheme.bgCard', 'AppTheme.bgCard(context)');
    content = content.replaceAll('AppTheme.bgSurface', 'AppTheme.bgSurface(context)');
    content = content.replaceAll('AppTheme.divider', 'AppTheme.divider(context)');
    content = content.replaceAll('Colors.white38', 'AppTheme.textFaint(context)');
    content = content.replaceAll('Colors.white54', 'AppTheme.textMuted(context)');
    content = content.replaceAll('Colors.white70', 'AppTheme.textMuted(context)');
    content = content.replaceAll('Colors.white', 'AppTheme.textMain(context)');

    // Fix possible double contexts if we ran it multiple times (safety)
    content = content.replaceAll('(context)(context)', '(context)');

    file.writeAsStringSync(content);
    print('Processed ${file.path}');
  }
}
