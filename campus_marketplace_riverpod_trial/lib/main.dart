import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'item.dart';
import 'favorites_notifier.dart';

void main() {
  // (ส่วนที่ 4) ครอบแอปด้วย ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// ====================================================
// (ส่วนที่ 4 + 5) หน้า HomePage + ช่องค้นหา (Search Box)
// ====================================================
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // (ส่วนที่ 5 - โจทย์ที่ 1) Ephemeral State สำหรับคำค้นหา
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // (ส่วนที่ 4) ref.watch อ่านข้อมูลรายการโปรด
    final savedItems = ref.watch(favoritesProvider);

    // (ส่วนที่ 5) กรองรายการสินค้าตามคำค้นหา
    final filteredCatalog = catalog.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Marketplace (Riverpod)'),
        actions: [
          IconButton(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite),
                Text(' ${savedItems.length}'),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // (ส่วนที่ 5 - โจทย์ที่ 1) ช่องค้นหาสินค้า
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'ค้นหาสินค้า...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Rebuild เพื่อกรองข้อมูลใหม่
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCatalog.length,
              itemBuilder: (context, index) {
                final item = filteredCatalog[index];
                final isSaved = savedItems.any((i) => i.id == item.id);

                return ListTile(
                  title: Text(item.title),
                  subtitle: Text('฿${item.price.toStringAsFixed(0)}'),
                  trailing: ElevatedButton(
                    onPressed: isSaved
                        ? null
                        : () {
                            // (ส่วนที่ 4) ref.read สั่งเพิ่มรายการ
                            ref.read(favoritesProvider.notifier).add(item);
                          },
                    child: Text(isSaved ? '❤️ บันทึกแล้ว' : '🤍 บันทึก'),
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

// ====================================================
// (ส่วนที่ 5) หน้า FavoritesPage + ปุ่มล้างรายการทั้งหมด
// ====================================================
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  // (ส่วนที่ 5 - โจทย์ที่ 2) Dialog ยืนยันการล้างข้อมูล
  void _showClearConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ยืนยันการล้างรายการโปรด'),
        content: const Text('คุณต้องการลบรายการที่บันทึกไว้ทั้งหมดหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              // (ส่วนที่ 5) ref.read สั่งล้างรายการทั้งหมด
              ref.read(favoritesProvider.notifier).clear();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('ล้างทั้งหมด', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedItems = ref.watch(favoritesProvider);
    final totalValue = ref.watch(favoritesProvider.notifier).totalValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการโปรดของฉัน'),
        actions: [
          // (ส่วนที่ 5 - โจทย์ที่ 2) แสดงปุ่มเฉพาะเมื่อมีรายการโปรดอย่างน้อย 1 รายการ
          if (savedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'ล้างรายการโปรดทั้งหมด',
              onPressed: () => _showClearConfirmDialog(context, ref),
            ),
        ],
      ),
      body: savedItems.isEmpty
          ? const Center(child: Text('ยังไม่มีสินค้าที่บันทึกไว้'))
          : ListView.builder(
              itemCount: savedItems.length,
              itemBuilder: (context, index) {
                final item = savedItems[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text('฿${item.price.toStringAsFixed(0)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(favoritesProvider.notifier).remove(item);
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('มูลค่ารวม: ฿${totalValue.toStringAsFixed(0)}'),
      ),
    );
  }
}