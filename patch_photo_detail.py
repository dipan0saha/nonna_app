import re

with open('lib/features/gallery/presentation/screens/photo_detail_screen.dart', 'r') as f:
    content = f.read()

content = content.replace("await db.client\n          .from(SupabaseTables.photoSquishes)\n          .select('id')", "await db.select(SupabaseTables.photoSquishes, columns: 'id')")
content = content.replace("await db.client\n            .from(SupabaseTables.photoSquishes)\n            .select('id')", "await db.select(SupabaseTables.photoSquishes, columns: 'id')")
content = content.replace("await db.client\n            .from(SupabaseTables.photoSquishes)\n            .delete()", "await db.delete(SupabaseTables.photoSquishes)")
content = content.replace("""        final response = await db.client
            .from(SupabaseTables.photoSquishes)
            .insert({
              'photo_id': widget.photo.id,
              'user_id': userId,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
            
        setState(() {
          _isSquished = true;
          _squishCount++;
          _squishId = response['id'] as String;
        });""", """        final responseList = await db.insert(SupabaseTables.photoSquishes, {
              'photo_id': widget.photo.id,
              'user_id': userId,
              'created_at': DateTime.now().toIso8601String(),
            });
            
        setState(() {
          _isSquished = true;
          _squishCount++;
          if (responseList.isNotEmpty) {
            _squishId = responseList.first['id'] as String;
          }
        });""")

with open('lib/features/gallery/presentation/screens/photo_detail_screen.dart', 'w') as f:
    f.write(content)
