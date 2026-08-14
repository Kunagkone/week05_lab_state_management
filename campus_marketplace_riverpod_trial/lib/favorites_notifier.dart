import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'item.dart';

class FavoritesNotifier extends StateNotifier<List<Item>> {
  FavoritesNotifier() : super([]); // ค่าเริ่มต้นคือลิสต์ว่าง

  // (ส่วนที่ 4) เพิ่มสินค้า
  void add(Item item) => state = [...state, item];

  // (ส่วนที่ 4) ลบสินค้า
  void remove(Item item) => state = state.where((i) => i.id != item.id).toList();

  // (ส่วนที่ 5) ล้างรายการโปรดทั้งหมด
  void clear() => state = [];

  // (ส่วนที่ 4) คำนวณราคารวม
  double get totalValue => state.fold(0, (sum, i) => sum + i.price);
}

// (ส่วนที่ 4) ประกาศ Provider เป็นตัวแปร Global
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Item>>(
  (ref) => FavoritesNotifier(),
);