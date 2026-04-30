import 'package:nonna_app/core/models/photo.dart';

void main() {
  final json = {
    'id': 'c7945420-0b17-4af8-8d70-72ec53e08d75',
    'baby_profile_id': 'b0000000-b001-b001-b001-00000000b001',
    'uploaded_by_user_id': '10000000-1001-1001-1001-000000001001',
    'storage_path': 'foo/bar.jpg',
    'thumbnail_path': null,
    'caption': 'Hello',
    'tags': null,
    'created_at': '2023-10-01T10:00:00Z',
    'updated_at': '2023-10-01T10:00:00Z',
    'deleted_at': null,
  };
  final p = Photo.fromJson(json);
  print(p.caption);
}
