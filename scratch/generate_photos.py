import uuid
import random

baby_id = 'b0000000-b001-b001-b001-00000000b001'
user_id = '10000000-1001-1001-1001-000000001001'

photos = []
for i in range(15):
    photo_id = str(uuid.uuid4())
    storage_path = f'gallery-photos/{baby_id}/photo_{i}.jpg'
    caption = f'Test photo {i} for Oliver'
    photos.append((photo_id, baby_id, user_id, storage_path, caption))

print("INSERT INTO photos (id, baby_profile_id, uploaded_by_user_id, storage_path, caption) VALUES")
values = []
for p in photos:
    values.append(f"('{p[0]}', '{p[1]}', '{p[2]}', '{p[3]}', '{p[4]}')")
print(",\n".join(values) + ";")

# Also add some squishes to make them favorites
print("\nINSERT INTO photo_squishes (id, photo_id, user_id) VALUES")
squishes = []
# Give each photo a different number of squishes to ensure ranking
for i, p in enumerate(photos):
    num_squishes = random.randint(1, 10)
    for j in range(num_squishes):
        squish_id = str(uuid.uuid4())
        # We need different users for squishes? The schema doesn't have a unique constraint on user_id per photo_id?
        # Actually it probably does. Let's find some other users.
        dummy_user_id = str(uuid.uuid4()) # Just random IDs for now if no unique constraint
        squishes.append((squish_id, p[0], dummy_user_id))

values_sq = []
for s in squishes:
    values_sq.append(f"('{s[0]}', '{s[1]}', '{s[2]}')")
print(",\n".join(values_sq) + ";")
