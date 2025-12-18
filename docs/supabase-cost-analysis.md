# Supabase Cost Calculator and Projections

**Purpose:** Detailed cost projections for various user scales and usage patterns  
**Last Updated:** December 2025

---

## 1. Pricing Components

### 1.1 Base Plan Pricing

| Plan | Monthly Cost | Included Resources |
|------|-------------|-------------------|
| **Free** | $0 | 500 MB database, 1 GB storage, 2 GB bandwidth, 50k MAU |
| **Pro** | $25 | 8 GB database, 8 GB storage, 50 GB bandwidth, 100k MAU |
| **Team** | $599 | 8 GB database, 100 GB storage, 250 GB bandwidth, 100k MAU |
| **Enterprise** | Custom | Custom resources, SLA, dedicated support |

### 1.2 Add-on Pricing (Pro/Team)

| Resource | Unit Price |
|----------|-----------|
| Database Compute (RAM) | $0.01344/GB/hour ($9.81/GB/month) |
| Database Storage | $0.125/GB/month |
| Bandwidth (Egress) | $0.09/GB |
| Point-in-Time Recovery | Included (7 days Pro, custom Team) |
| Custom Domain SSL | Free |
| Read Replicas | Coming soon |

---

## 2. User Scenario Projections

### Scenario A: Lightweight Social App (10,000 users)

**User Behavior:**
- 10,000 registered users
- 30% monthly active users (3,000 MAU)
- 15% daily active users (1,500 DAU)
- 300 concurrent users at peak
- 50 API requests per user per day
- 20 real-time messages per user per day
- 5 MB storage per user (profile + media)

**Resource Requirements:**

**Database:**
- Compute: 8-16 GB RAM, 2-4 cores (moderate load)
- Storage: 50 GB (users + content)
- Connections: ~500 concurrent (within pooler limits)

**Bandwidth:**
- API requests: 3,000 MAU × 50 req/day × 30 days × 10 KB = ~45 GB/month
- Realtime: 3,000 MAU × 20 msg/day × 30 days × 1 KB = ~1.8 GB/month
- Media: 3,000 MAU × 100 MB/month = ~300 GB/month
- **Total Bandwidth:** ~350 GB/month

**Cost Breakdown (Pro Plan):**
```
Base Pro Plan:                    $25.00
Additional Compute (8 GB RAM):    $78.48  (8 GB × $9.81)
Additional Storage (42 GB):        $5.25  (42 GB × $0.125)
Additional Bandwidth (300 GB):    $27.00  (300 GB × $0.09)
─────────────────────────────────────────
Total Monthly Cost:              $135.73
Cost per User:                     $0.014
```

**Alternative (Team Plan):**
```
Base Team Plan:                  $599.00
Additional Storage: (0 GB)         $0.00  (100 GB included)
Additional Bandwidth (100 GB):     $9.00  (300 - 250 GB overage)
─────────────────────────────────────────
Total Monthly Cost:              $608.00
Cost per User:                     $0.061
```

**Recommendation:** Pro Plan is more cost-effective for this scale.

---

### Scenario B: Real-time Messaging App (10,000 users)

**User Behavior:**
- 10,000 registered users
- 50% monthly active users (5,000 MAU)
- 25% daily active users (2,500 DAU)
- 500 concurrent users at peak
- 200 API requests per user per day
- 100 real-time messages per user per day
- 10 MB storage per user

**Resource Requirements:**

**Database:**
- Compute: 16-32 GB RAM, 4-8 cores (high real-time load)
- Storage: 100 GB
- Connections: ~1,000 concurrent

**Bandwidth:**
- API requests: 5,000 MAU × 200 req/day × 30 days × 10 KB = ~300 GB/month
- Realtime: 5,000 MAU × 100 msg/day × 30 days × 2 KB = ~30 GB/month
- Media: 5,000 MAU × 50 MB/month = ~250 GB/month
- **Total Bandwidth:** ~580 GB/month

**Cost Breakdown (Pro Plan):**
```
Base Pro Plan:                    $25.00
Additional Compute (24 GB RAM):  $235.44  (24 GB × $9.81)
Additional Compute (4 cores):    ~$120.00  (estimated)
Additional Storage (92 GB):       $11.50  (92 GB × $0.125)
Additional Bandwidth (530 GB):    $47.70  (530 GB × $0.09)
─────────────────────────────────────────
Total Monthly Cost:              $439.64
Cost per User:                     $0.044
```

**Alternative (Team Plan):**
```
Base Team Plan:                  $599.00
Additional Compute (24 GB):      $235.44
Additional Compute (4 cores):    ~$120.00
Additional Bandwidth (330 GB):    $29.70  (330 GB overage)
─────────────────────────────────────────
Total Monthly Cost:              $984.14
Cost per User:                     $0.098
```

**Recommendation:** Pro Plan is still more cost-effective. Team plan provides better support.

---

### Scenario C: Media-Heavy Social Platform (10,000 users)

**User Behavior:**
- 10,000 registered users
- 40% monthly active users (4,000 MAU)
- 20% daily active users (2,000 DAU)
- 400 concurrent users at peak
- 100 API requests per user per day
- 30 real-time notifications per user per day
- 50 MB storage per user (high media content)

**Resource Requirements:**

**Database:**
- Compute: 16 GB RAM, 4 cores
- Storage: 500 GB (media-heavy)
- Connections: ~800 concurrent

**Bandwidth:**
- API requests: 4,000 MAU × 100 req/day × 30 days × 10 KB = ~120 GB/month
- Realtime: 4,000 MAU × 30 notif/day × 30 days × 1 KB = ~3.6 GB/month
- Media: 4,000 MAU × 500 MB/month = ~2,000 GB/month
- **Total Bandwidth:** ~2,125 GB/month

**Cost Breakdown (Pro Plan):**
```
Base Pro Plan:                     $25.00
Additional Compute (8 GB RAM):     $78.48
Additional Storage (492 GB):       $61.50  (492 GB × $0.125)
Additional Bandwidth (2,075 GB):  $186.75  (2,075 GB × $0.09)
─────────────────────────────────────────
Total Monthly Cost:               $351.73
Cost per User:                      $0.035
```

**Recommendation:** Consider using external CDN (Cloudflare, AWS CloudFront) for media to reduce bandwidth costs. With CDN, bandwidth could drop to ~200 GB, saving ~$168/month.

**With CDN:**
```
Total Monthly Cost:               $183.73
Cost per User:                      $0.018
```

---

## 3. Scaling Projections

### 3.1 User Growth Projections

| Users | MAU (40%) | DAU (20%) | Concurrent (3%) | Est. Monthly Cost (Pro) |
|-------|-----------|-----------|-----------------|------------------------|
| 5,000 | 2,000 | 1,000 | 150 | $80-120 |
| 10,000 | 4,000 | 2,000 | 300 | $150-250 |
| 25,000 | 10,000 | 5,000 | 750 | $400-600 |
| 50,000 | 20,000 | 10,000 | 1,500 | $800-1,200 |
| 100,000 | 40,000 | 20,000 | 3,000 | $1,800-2,500 |

### 3.2 Break-even Analysis: Pro vs Team Plan

**Team Plan becomes cost-effective when:**
- Bandwidth needs > 800 GB/month (saves $0.09/GB on overage)
- Storage needs > 200 GB (saves $0.125/GB)
- Need for priority support and team features
- Around 15,000-20,000 active users with moderate usage

**Calculation:**
```
Team Plan Base: $599
Pro Plan Base: $25

Break-even = ($599 - $25) / (bandwidth savings + storage savings)
Break-even ≈ 15,000-20,000 users (depending on usage patterns)
```

---

## 4. Cost Optimization Strategies

### 4.1 Database Optimization (Potential Savings: 30-50%)

**Strategies:**
1. **Proper Indexing:** Reduce compute needs by 20-30%
2. **Query Optimization:** Reduce database load
3. **Data Archiving:** Move old data to cold storage
4. **Compression:** Reduce storage by 40-60%

**Example:**
- Before: 32 GB RAM needed
- After optimization: 16 GB RAM needed
- **Savings:** ~$157/month

### 4.2 Bandwidth Optimization (Potential Savings: 40-70%)

**Strategies:**
1. **CDN for Media:** Reduce Supabase bandwidth by 80%
2. **Image Compression:** Reduce bandwidth by 60-70%
3. **Lazy Loading:** Reduce unnecessary data transfer
4. **Caching:** Client-side caching reduces API calls

**Example:**
- Before: 2,000 GB/month bandwidth
- After CDN + optimization: 400 GB/month
- **Savings:** $144/month

### 4.3 Storage Optimization (Potential Savings: 50-70%)

**Strategies:**
1. **Image Compression:** WebP format saves 50-70%
2. **Tiered Storage:** Move old files to S3 Glacier
3. **Deduplication:** Remove duplicate files
4. **Cleanup:** Delete unused/orphaned files

**Example:**
- Before: 500 GB storage
- After optimization: 200 GB storage
- **Savings:** $37.50/month

---

## 5. Comparison with Competitors

### 5.1 Feature Comparison (10,000 users, moderate usage)

| Provider | Monthly Cost | Real-time | Auth | Storage | Complexity |
|----------|-------------|-----------|------|---------|-----------|
| **Supabase** | $150-250 | ✅ Included | ✅ Included | ✅ 100 GB | Low |
| **Firebase** | $200-400 | ✅ Included | ✅ Included | ⚠️ Pay per GB | Medium |
| **AWS Amplify** | $300-500 | ⚠️ Manual setup | ✅ Cognito | ✅ S3 | High |
| **Back4App** | $150-300 | ✅ Included | ✅ Included | ✅ 50 GB | Low |
| **Heroku + Postgres** | $250-400 | ❌ Build yourself | ❌ Build yourself | ⚠️ Add-on | Medium |

### 5.2 Total Cost of Ownership (TCO) - 1 Year

**Scenario:** 10,000 users, growing to 15,000

| Provider | Infrastructure | Development | Maintenance | Total (1 year) |
|----------|---------------|-------------|-------------|----------------|
| **Supabase** | $2,400 | $5,000 | $1,000 | **$8,400** |
| **Firebase** | $3,600 | $4,000 | $1,500 | **$9,100** |
| **AWS Amplify** | $4,800 | $8,000 | $3,000 | **$15,800** |
| **Custom Backend** | $6,000 | $20,000 | $5,000 | **$31,000** |

**Notes:**
- Development costs include initial setup and integration
- Maintenance includes monitoring, updates, and bug fixes
- Supabase offers best TCO for small-to-medium scale apps

---

## 6. Financial Planning

### 6.1 Budget Recommendations

**Launch Budget (First 3 months):**
- Months 1-2: Free tier (development & testing) - $0
- Month 3: Pro plan (soft launch, 1,000 users) - $50
- **Total:** $50

**Growth Budget (Months 4-12):**
- Months 4-6: Pro plan (5,000 users) - $150/month
- Months 7-9: Pro plan (8,000 users) - $200/month
- Months 10-12: Pro/Team plan (10,000 users) - $250/month
- **Total:** $1,800

**Year 1 Total:** $1,850

### 6.2 Revenue Requirements

**To maintain 30% profit margin:**

At 10,000 users, $200/month cost:
- Required revenue: $200 / 0.7 = $286/month
- Revenue per user: $286 / 10,000 = **$0.029/month**

**Monetization options:**
- Freemium: 5% conversion at $5/month = $2,500/month ✅
- Ads: $0.50 CPM, 10 views/user/day = $1,500/month ✅
- Subscriptions: 2% at $10/month = $2,000/month ✅

**All monetization strategies easily cover costs with margin.**

---

## 7. Risk Assessment and Contingency

### 7.1 Cost Overrun Scenarios

**Worst Case Scenarios:**

1. **Viral Growth (50,000 users in 1 month):**
   - Projected cost: $800-1,200/month
   - **Mitigation:** Set billing alerts, cap resources, scale gradually

2. **DDoS Attack:**
   - Potential cost: $2,000+ in bandwidth
   - **Mitigation:** Enable rate limiting, use Cloudflare

3. **Data Migration:**
   - One-time cost: $500-2,000
   - **Mitigation:** Plan migrations during off-peak, test thoroughly

### 7.2 Billing Alerts Configuration

**Recommended Alerts:**
```
Alert 1: Monthly spend > $150 (email notification)
Alert 2: Monthly spend > $300 (email + SMS)
Alert 3: Monthly spend > $500 (email + SMS + pause resources)
Alert 4: Bandwidth > 500 GB (warning)
Alert 5: Storage > 200 GB (warning)
```

---

## 8. Cost Calculator Tool

### 8.1 Formula

```
Monthly Cost = Base Plan 
             + (Extra RAM × $9.81)
             + (Extra vCPU × $30/core estimated)
             + (Extra Storage × $0.125)
             + (Extra Bandwidth × $0.09)

Where:
- Extra RAM = max(0, Required RAM - Included RAM)
- Extra Storage = max(0, Required Storage - Included Storage)
- Extra Bandwidth = max(0, Required Bandwidth - Included Bandwidth)
```

### 8.2 Example Calculation

**Input:**
- Users: 10,000
- Avg API requests/user/day: 50
- Avg real-time messages/user/day: 20
- Storage per user: 10 MB
- MAU rate: 40%

**Calculation:**
```python
# Users
total_users = 10000
mau = total_users * 0.4  # 4,000

# Database Compute
concurrent_users = total_users * 0.03  # 300
required_ram_gb = max(8, concurrent_users / 20)  # ~15 GB
extra_ram = max(0, required_ram_gb - 8)  # 7 GB

# Storage
total_storage_gb = (total_users * 10) / 1024  # ~98 GB
extra_storage = max(0, total_storage_gb - 8)  # 90 GB

# Bandwidth
api_bandwidth = mau * 50 * 30 * 0.00001  # ~60 GB
realtime_bandwidth = mau * 20 * 30 * 0.000002  # ~4.8 GB
media_bandwidth = mau * 0.1  # ~400 GB
total_bandwidth = api_bandwidth + realtime_bandwidth + media_bandwidth  # ~465 GB
extra_bandwidth = max(0, total_bandwidth - 50)  # 415 GB

# Cost
base_cost = 25
compute_cost = extra_ram * 9.81  # $68.67
storage_cost = extra_storage * 0.125  # $11.25
bandwidth_cost = extra_bandwidth * 0.09  # $37.35

total_cost = base_cost + compute_cost + storage_cost + bandwidth_cost
# Total: $142.27
```

---

## 9. Long-term Projections (3 Years)

### Year 1: 10,000 users
- Monthly cost: $150-250
- Annual cost: $1,800-3,000
- Plan: Pro

### Year 2: 30,000 users
- Monthly cost: $400-700
- Annual cost: $4,800-8,400
- Plan: Team

### Year 3: 60,000 users
- Monthly cost: $1,000-1,800
- Annual cost: $12,000-21,600
- Plan: Team/Enterprise

**3-Year TCO:** $18,600-33,000

**vs. Custom Backend TCO:** $100,000-150,000 (infrastructure + 2 backend engineers)

**Savings with Supabase:** $66,000-117,000 over 3 years

---

## 10. Summary and Recommendations

### 10.1 Key Findings

✅ **Supabase is cost-effective** for 10,000 users at $150-250/month  
✅ **Scales linearly** with user growth  
✅ **Better TCO** than competitors and custom solutions  
✅ **Low risk** with free tier for testing  
✅ **Predictable costs** with clear pricing model  

### 10.2 Action Items

1. **Start with Free Tier** for development and testing
2. **Upgrade to Pro** before public launch
3. **Set billing alerts** at $150, $300, $500
4. **Implement CDN** for media to reduce bandwidth costs
5. **Monitor usage** and optimize database/storage monthly
6. **Plan for Team Plan** at 15,000-20,000 users
7. **Consider Enterprise** at 50,000+ users for SLA

### 10.3 Final Recommendation

**Proceed with Supabase** - Cost-effective, scalable, and proven solution for 10,000 users with real-time requirements.

**Expected ROI:** 
- Cost: $150-250/month
- Required revenue: $300-400/month (with margin)
- Achievable with minimal monetization

---

**Last Updated:** December 2025  
**Maintained by:** Product Team  
**Review Frequency:** Quarterly
