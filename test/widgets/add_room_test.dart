import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/models/agenda.dart';
import 'package:sec/presentation/ui/widgets/add_room.dart';

void main() {
  group('AddRoom Widget', () {
    late List<Track> rooms;
    late List<Track> editedRoomsResult;
    late Track removedRoomResult;

    setUp(() {
      rooms = [
        Track(
          uid: '1',
          name: 'Room 1',
          color: '',
          sessionUids: [],
          eventUid: 'event1',
        ),
        Track(
          uid: '2',
          name: 'Room 2',
          color: '',
          sessionUids: [],
          eventUid: 'event1',
        ),
      ];
      editedRoomsResult = [];
      removedRoomResult = Track(
        uid: '',
        name: '',
        color: '',
        sessionUids: [],
        eventUid: '',
      );
    });

    Future<void> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddRoom(
              rooms: rooms,
              editedRooms: (updatedRooms) => editedRoomsResult = updatedRooms,
              removeRoom: (removedRoom) => removedRoomResult = removedRoom,
              eventUid: 'event1',
            ),
          ),
        ),
      );
    }

    testWidgets('should display initial rooms', (WidgetTester tester) async {
      await pumpWidget(tester);

      expect(find.widgetWithText(TextField, 'Room 1'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Room 2'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should add a new room when "Add Option" is tapped', (
      WidgetTester tester,
    ) async {
      await pumpWidget(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('should update room name on text field change', (
      WidgetTester tester,
    ) async {
      await pumpWidget(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Room 1'),
        'Updated Room 1',
      );
      await tester.pump();

      expect(editedRoomsResult.first.name, 'Updated Room 1');
    });

    testWidgets(
      'should remove a room when remove button is tapped and confirmed',
      (WidgetTester tester) async {
        rooms = [
          Track(
            uid: '1',
            name: 'Room 1',
            color: '',
            sessionUids: [],
            eventUid: 'event1',
          ),
        ];
        await pumpWidget(tester);

        expect(find.widgetWithText(TextField, 'Room 1'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.remove_circle));
        await tester.pumpAndSettle(); // Wait for the dialog to appear

        expect(find.text('¿Deseas eliminar esta opción?'), findsOneWidget);

        await tester.tap(find.text('Eliminar'));
        await tester
            .pumpAndSettle(); // Wait for the dialog to close and widget to rebuild

        expect(find.widgetWithText(TextField, 'Room 1'), findsNothing);
        expect(removedRoomResult.uid, '1');
        expect(editedRoomsResult.isEmpty, isTrue);
      },
    );
  });
}
