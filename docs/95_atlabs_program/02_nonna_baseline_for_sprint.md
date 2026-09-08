# Nonna — Baseline Context for AltaLab Assignments

Use this document when completing AltaLab sprint assignments. It has two layers:

1. **Internal context** — full truth for agents (repo, codebase, traction)
2. **External positioning** — what goes in Evolve submissions (early-stage founder voice)

Full technical detail lives in `docs/99_master_reference_docs/`.

**AltaLab email:** `lanonnaapp@gmail.com`  
**Track:** Core Track (all chapters)

---

## One-Liner

**Nonna** is a private, invite-only mobile app where expectant/new parents share their baby's journey — photos, events, and registry — with family and friends in one place.

**Tagline:** Private. Organized. Connected.

---

## External Positioning (AltaLab Submissions)

**Founder preference:** Present Nonna as an **early-stage** project going through the Core Track honestly — do **not** disclose internal build progress, architecture depth, or how much of the app is already done.

| Share with AltaLab | Keep internal (agents/repo only) |
|--------------------|----------------------------------|
| Problem, ICP, market pain points | Flutter/Supabase stack, tile engine, edge functions |
| Vision: photos + calendar + registry in one private app | Feature completion %, v1.0.0 status, 18 tiles |
| Customer discovery in progress | Detailed MVP feature checklist |
| Early validation (surveys, conversations, waitlist interest) | Specific beta signup counts unless Dipan approves |
| MVP **roadmap** and what to build next | What's already built in the repo |
| Competitor landscape (FamilyAlbum, Tinybeans) | CI/CD gaps, localization debt, system gaps doc |
| Founder story and why Nonna | Fundraising ask details unless assignment asks |

**Voice for submissions:** "We're validating the problem and shaping our MVP" — not "we've built 40% of the product."

**Track choice:** Use **Core Track** for every chapter. The assessment map is a recommendation only; Dipan prefers Core regardless of result.

---

| Pain | Data Point |
|------|------------|
| Parents won't post baby photos on public social | 73% uncomfortable (2024 survey) |
| Families are geographically scattered | 57% of millennials 500+ miles from parents |
| Tool fragmentation | Photos (Google), events (email), registry (Amazon) — separate apps |
| Passive engagement on photo-only apps | Family wants to participate, not just view |

**Core insight:** Families need one **private hub** — not another social network.

---

## Solution

| Pillar | What Nonna Does |
|--------|-----------------|
| **Photos** | Private gallery, squish (like), comments, tags |
| **Calendar** | Milestones, RSVPs, video links, reminders |
| **Registry** | Wishlist, purchase tracking, duplicate-gift prevention |
| **Engagement** | Name suggestions, gender/birthdate predictions, activity stats |
| **Roles** | **Owner** (parent, full control) vs **Follower** (family, read + interact) |

**Differentiation:** Only integrated platform combining photos + calendar + registry. Competitors (FamilyAlbum, Tinybeans) are photo-only.

---

## Target Customer (ICP)

### Primary — Tech-savvy new parents (Owners)
- Age 25–40, $60K–$120K household, urban/suburban
- Privacy-conscious, frustrated by app fragmentation
- Wants distant family included without public posting

### Secondary — Engaged grandparents (Followers)
- Age 55–70, moderate/low tech, 500+ miles away
- Needs simplicity, emotional connection, gift participation

### Tertiary — Close friends (Followers)
- Want to support without social media exposure

---

## Business Model

| Tier | Price | Limits |
|------|-------|--------|
| Free | $0 | 15GB storage, 20 followers/baby |
| Premium | $6.99/mo | Unlimited storage & profiles |
| Secondary revenue | Affiliate + print partnerships | Registry commissions |

**Targets:** 10–15% premium conversion, viral coefficient 1.5+ (5+ family invites per parent)

---

## Market

- **TAM narrative:** $2.1B family/baby sharing market by 2030
- **Audience:** ~60M smartphone-using parents globally
- **Competitors:** FamilyAlbum (~20M users, photos only), Tinybeans (~5M, 1GB limit)

---

## Traction & Stage

### Internal (agents only — Sep 2026)

| Area | Status |
|------|--------|
| **Product** | Flutter MVP substantially built — not pre-idea |
| **Version** | v1.0.0 codebase |
| **Architecture** | 18 dynamic tiles, Supabase backend, 6 edge functions |
| **Beta** | 500+ signups; 89% interest in parent survey (per deck) |
| **Fundraising** | Seeking $500K–$750K seed (per elevator pitch) |
| **Team** | Solo founder (Dipan Saha) |

### External (AltaLab submissions)

| Area | How to describe |
|------|-----------------|
| **Stage** | Early-stage founder validating problem and shaping MVP |
| **Product** | Concept defined; building toward a focused first version |
| **Validation** | Parent surveys and conversations confirm strong interest in private family sharing |
| **Traction** | Early waitlist / outreach — avoid specific internal metrics unless Dipan approves |
| **Team** | Solo founder building La Nonna |

---
## Tech Stack (Internal — agents only)

| Layer | Tech |
|-------|------|
| Mobile | Flutter + Material 3 |
| State | Riverpod v3 |
| Backend | Supabase (Auth, PostgreSQL, Storage, Realtime) |
| Push | OneSignal |
| Analytics | Firebase |

**Architectural highlight:** Tile Engine — features configured via Supabase, not hardcoded screens. Enables fast product iteration without app releases.

---

## What's Built (Internal — agents only)

- Auth (Google, Facebook, email, biometrics)
- Baby profiles (dual-owner support, soft delete)
- Invite-only followers (email invitations)
- Home screen with 18 role-aware tiles
- Gallery, calendar, registry, gamification screens
- Push notifications + deep links
- EN/ES localization (partial — some gaps)
- Offline cache + connectivity handling

---

## Known Gaps (Internal — agents only)

| Gap | Severity | Sprint relevance |
|-----|----------|------------------|
| Spanish localization incomplete | Medium | PMF — bilingual market |
| Email-only invites (no share link/QR) | Low | Growth loop friction |
| No cloud device testing CI | High | Launch readiness |
| PMF metrics not yet proven at scale | High | Core AltaLab focus |

Full list: `docs/99_master_reference_docs/Current_System_Gaps.md`

---

## Hypotheses to Test During Sprint

AltaLab will push focus — these are Nonna's open questions:

1. **ICP narrow enough?** All new parents vs. privacy-first, geographically separated families?
2. **Core loop?** Is "invite family → share photos → they engage" the one metric that matters?
3. **Wedge feature?** Photos alone, or integrated calendar/registry as differentiator?
4. **Monetization timing?** Freemium at 15GB vs. earlier premium conversion?
5. **Geography?** US-first vs. bilingual US+Hispanic market?
6. **Fundraising story?** "$2.1B market" vs. focused beachhead narrative?

Document answers as each AltaLab chapter asks.

---

## Pitch Snippets (Ready to Adapt)

### Investor (30 sec) — external version
> Nonna is a private family platform for baby milestones. 73% of parents won't post baby photos publicly; families juggle photos, events, and registries across apps. We're building one invite-only mobile app that combines all three. We're validating with parents and shaping our MVP now.

### User (30 sec)
> Nonna is your private family hub for your baby's journey. Share photos only with people you invite, coordinate events with RSVPs, and manage your registry — no Facebook, no juggling five apps.

_For investor deck copy with metrics, see `Elevator_Pitch.md` — internal use only unless Dipan approves for a specific assignment._

---

## Key Files for Agents

| Need | File |
|------|------|
| Full product spec | `docs/99_master_reference_docs/Nonna_Project_Understanding.md` |
| Architecture | `docs/99_master_reference_docs/Nonna_Architecture_and_Workflow_Reference.md` |
| Investor narrative | `docs/98_investor_and_marketing_strategy/Investment_Deck.md` |
| GTM | `docs/98_investor_and_marketing_strategy/Marketing_Strategy_Document.md` |

---

*Last updated: 2026-09-07 (email + Core Track + external positioning)*
