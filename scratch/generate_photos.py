import uuid
import random

baby_id = 'b0000000-b001-b001-b001-00000000b001'
user_id = '10000000-1001-1001-1001-000000001001'

# Existing user IDs to avoid FK violations
user_ids = [
    '40000000-4001-4001-4001-000000004001',
    '40000001-4001-4001-4001-000000004001',
    '40000002-4001-4001-4001-000000004001',
    '40000003-4001-4001-4001-000000004001',
    '40000004-4001-4001-4001-000000004001',
    '40000006-4001-4001-4001-000000004001',
    '40000007-4001-4001-4001-000000004001'
]

photos = []
for i in range(15):
    photo_id = str(uuid.uuid4())
    storage_path = f'gallery-photos/{baby_id}/photo_{i}.jpg'
    caption = f'Test photo {i} for Oliver'
    photos.append((photo_id, baby_id, user_id, storage_path, caption))

# Use only photos that we just generated
print("INSERT INTO photos (id, baby_profile_id, uploaded_by_user_id, storage_path, caption) VALUES")
values = []
for p in photos:
    values.append(f"('{p[0]}', '{p[1]}', '{p[2]}', '{p[3]}', '{p[4]}')")
print(",\n".join(values) + ";")

# Also add some squishes to make them favorites
print("\nINSERT INTO photo_squishes (id, photo_id, user_id) VALUES")
squishes = []
for i, p in enumerate(photos):
    # Give each photo a different number of squishes to ensure ranking
    # The more photos, the more "more" there is to see
    num_squishes = (i % 7) + 1 
    for j in range(num_squishes):
        squish_id = str(uuid.uuid4())
        # Use users from the list to avoid unique constraint if we repeat? 
        # Actually user_id + photo_id is probably unique.
        squishes.append((squish_id, p[0], user_ids[j]))

values_sq = []
for s in squishes:
    values_sq.append(f"('{s[0]}', '{s[1]}', '{s[2]}')")
print(",\n".join(values_sq) + ";")
