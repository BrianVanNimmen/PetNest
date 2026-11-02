import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petnest/app.dart';
import 'package:petnest/strings.dart';

void main() {
  testWidgets('starts on the login screen and opens registration', (
    tester,
  ) async {
    await tester.pumpWidget(const PetNestApp());
    await tester.pumpAndSettle();

    expect(find.text(Strings.areYouVetOrOwner), findsOneWidget);
    expect(find.text(Strings.createAccount), findsOneWidget);

    await tester.tap(find.text(Strings.createAccount));
    await tester.pumpAndSettle();

    expect(find.text(Strings.chooseAccountType), findsOneWidget);
    expect(find.text(Strings.registerAsVet), findsOneWidget);
  });

  testWidgets('dark mode toggle switches the theme', (tester) async {
    await tester.pumpWidget(const PetNestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(Strings.accessibility));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Switch))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Switch))).brightness,
      Brightness.dark,
    );
  });
}
