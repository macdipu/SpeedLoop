import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/features/dashcam/presentation/widgets/clip_preview_sheet.dart';

void main() {
  test('preview starts two seconds before the incident', () {
    expect(
      incidentPreviewStart(
        incidentOffsetMs: 9000,
        duration: const Duration(seconds: 60),
      ),
      const Duration(seconds: 7),
    );
  });

  test('preview seek is bounded at the beginning and end of the clip', () {
    expect(
      incidentPreviewStart(
        incidentOffsetMs: 1000,
        duration: const Duration(seconds: 60),
      ),
      Duration.zero,
    );
    expect(
      incidentPreviewStart(
        incidentOffsetMs: 90000,
        duration: const Duration(seconds: 60),
      ),
      const Duration(seconds: 60),
    );
  });
}
