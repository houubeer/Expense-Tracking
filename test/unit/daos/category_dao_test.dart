import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/category_dao.dart';
import 'package:flutter_test/flutter_test.dart' hide isNull;
import 'package:matcher/matcher.dart' as matcher;

void main() {
  late AppDatabase database;
  late CategoryDao dao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = CategoryDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('CategoryDao', () {
    test('insertCategory creates new category', () async {
      const category = CategoriesCompanion(
        name: Value('Food'),
        iconCodePoint: Value('123'),
        color: Value(0xFF000000),
        budget: Value(1000.0),
      );

      final id = await dao.insertCategory(category);

      expect(id, greaterThan(0));

      final categories = await dao.getAllCategories();
      expect(categories.length, 1);
      expect(categories.first.name, 'Food');
      expect(categories.first.budget, 1000.0);
    });

    test('getAllCategories returns all categories', () async {
      await dao.insertCategory(const CategoriesCompanion(
        name: Value('Food'),
        iconCodePoint: Value('123'),
        color: Value(0xFF000000),
        budget: Value(1000.0),
      ));

      await dao.insertCategory(const CategoriesCompanion(
        name: Value('Transport'),
        iconCodePoint: Value('456'),
        color: Value(0xFFFFFFFF),
        budget: Value(500.0),
      ));

      final categories = await dao.getAllCategories();

      expect(categories.length, 2);
      expect(categories.map((c) => c.name), containsAll(['Food', 'Transport']));
    });

    test('getCategoryById returns correct category', () async {
      final id = await dao.insertCategory(const CategoriesCompanion(
        name: Value('Food'),
        iconCodePoint: Value('123'),
        color: Value(0xFF000000),
        budget: Value(1000.0),
      ));

      final category = await dao.getCategoryById(id);

      expect(category, matcher.isNotNull);
      expect(category!.id, id);
      expect(category.name, 'Food');
    });

    test('getCategoryById returns null for non-existent id', () async {
      final category = await dao.getCategoryById(999);

      expect(category, matcher.isNull);
    });

    test('updateCategory modifies category', () async {
      final id = await dao.insertCategory(const CategoriesCompanion(
        name: Value('Food'),
        iconCodePoint: Value('123'),
        color: Value(0xFF000000),
        budget: Value(1000.0),
      ));

      final original = await dao.getCategoryById(id);
      final updated = original!.copyWith(
        name: 'Groceries',
        budget: 1500.0,
      );

      await dao.updateCategory(updated);

      final retrieved = await dao.getCategoryById(id);

      expect(retrieved!.name, 'Groceries');
      expect(retrieved.budget, 1500.0);
    });

    test('deleteCategory removes category', () async {
      final id = await dao.insertCategory(const CategoriesCompanion(
        name: Value('Food'),
        iconCodePoint: Value('123'),
        color: Value(0xFF000000),
        budget: Value(1000.0),
      ));

      await dao.deleteCategory(id);

      final category = await dao.getCategoryById(id);
      expect(category, matcher.isNull);
    });

    test('updateCategorySpent updates spent amount', () async {
      final id = await dao.insertCategory(const CategoriesCompanion(
        name: Value('Food'),
        iconCodePoint: Value('123'),
        color: Value(0xFF000000),
        budget: Value(1000.0),
      ));

      await dao.updateCategorySpent(id, 250.0, 1);

      final category = await dao.getCategoryById(id);

      expect(category!.spent, 250.0);
      expect(category.version, 2);
    });

    test('watchAllCategories streams category updates', () async {
      final stream = dao.watchAllCategories();

      // Insert category
      await dao.insertCategory(const CategoriesCompanion(
        name: Value('Food'),
        iconCodePoint: Value('123'),
        color: Value(0xFF000000),
        budget: Value(1000.0),
      ));

      await expectLater(
        stream,
        emits(predicate<List<Category>>((list) => list.length == 1)),
      );
    });

    // Note: watchCategoryById, getTotalBudget, and getTotalSpent are not methods of CategoryDao
    // These are implemented in the repository layer
  });
}
