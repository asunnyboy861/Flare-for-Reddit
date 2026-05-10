# Flare for Reddit - iOS Development Guide

## Executive Summary

**Flare for Reddit** is a minimal, ad-free Reddit client for iOS that restores the swipe-first browsing experience Reddit removed from its official app. Targeting the US and global English-speaking market, Flare addresses the top pain points reported by 3,200+ Reddit users: deceptive ads, removed swipe navigation, frequent crashes, and forced auto-refresh.

**Key Differentiators**:
1. **Swipe-First Design** — Left/right swipe between posts (the feature Reddit removed)
2. **Zero-Ad Architecture** — Multi-layer ad filtering removes all promoted/sponsored content
3. **Instant Performance** — Cold start < 1s, 60fps scrolling, < 100MB memory

**Target Users**: Apollo refugees (40%), Reddit power users (25%), privacy-conscious users (15%), casual browsers (20%)

**Monetization**: Freemium with subscription (Free + $1.99/mo + $9.99/yr + $29.99 lifetime)

---

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **Reddit Official** | Full features, free | Heavy ads, no swipe nav, crashes, forced refresh | Zero ads, swipe navigation, stable, fast |
| **Narwhal 2** | Gesture-based, customizable, no ads | $3.99/mo subscription required, traditional UI | 50% cheaper ($1.99/mo), swipe-first design, modern UI |
| **Artemis for Reddit** | Liquid Glass design, modern, gesture support | New app, limited track record, smaller community | Proven architecture, lower price point, swipe core focus |
| **Infinity for Reddit iOS** | Open source, feature-rich, free | Complex UI, partial swipe support, not polished | Simplified UX, full swipe navigation, premium feel |

**Market Gap**: No existing Reddit client combines swipe-first navigation, zero ads, AND modern minimal design at an affordable price point.

---

## Feature Inventory (MANDATORY — Every Feature Must Be Listed)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | **Zero-Ad Feed Browsing** | 1. User opens app → 2. Feed loads → 3. User scrolls through ad-free posts | Subreddit selection, sort type (hot/new/rising/top) | RedditAPIService fetches posts → AdFilterService removes promoted/sponsored → CacheService saves | Clean post list with no ads | GRDB cache (TTL 30min) | Feed contains zero promoted/sponsored posts; all ad fields filtered |
| 2 | **Swipe Navigation** | 1. User views post card → 2. Swipes left → 3. Next post slides in with spring animation | DragGesture (direction, velocity, distance) | SwipeGestureHandler detects threshold (>50pt, >200pt/s) → PostNavigator updates index → Preload buffer checked | Smooth post transition with spring animation | currentIndex in ViewModel | Left swipe goes to next post; right swipe goes to previous; spring animation at 350ms |
| 3 | **Post Detail View** | 1. User taps post card → 2. Post detail opens → 3. Content renders (text/image/video) → 4. Swipe up for comments | Post ID, subreddit name | RedditAPIService.getPostComments() → Markdown rendering → Media type detection | Full post content + metadata | GRDB post detail cache | Post renders with title, author, time, content, media; markdown renders correctly |
| 4 | **Comment System** | 1. User scrolls to comments → 2. Tree structure displays → 3. User can upvote/downvote/reply (Pro) | Comment ID, vote direction, reply text | Comment tree parsing → Recursive nesting → Collapsed/expanded state | Threaded comment list with indentation | Vote state in UserDefaults | Comments display in tree structure; indentation shows depth; vote state persists |
| 5 | **Search** | 1. User taps search tab → 2. Types query → 3. Results show posts and subreddits | Search query string | RedditAPIService.search() → Result ranking → Ad filtering | Search results list (posts + subreddits) | Recent searches in UserDefaults | Search returns relevant results; recent searches shown; trending topics displayed |
| 6 | **Dark Mode** | 1. User long-presses status bar OR toggles in settings → 2. Theme switches instantly | Theme preference (light/dark/system) | Color scheme swap → All views re-render with theme colors | Instant theme change across all views | UserDefaults theme key | Dark mode uses OLED black (#000000); toggle is instant; respects system setting |
| 7 | **User Authentication** | 1. User taps "Continue with Reddit" → 2. Safari opens OAuth → 3. User authorizes → 4. Returns to app | OAuth2 authorization code | AuthService exchanges code for tokens → Keychain stores securely | Authenticated user session | Keychain (tokens), UserDefaults (username) | OAuth flow completes; token stored in Keychain; session persists across launches |
| 8 | **Anonymous Browsing** | 1. User taps "Browse without account" → 2. App loads popular feed without login | None | RedditAPIService uses client_credentials grant → No user context | Popular/hot feed without personalization | None (stateless) | Anonymous mode works without any login; no user data stored |
| 9 | **Subreddit Management** | 1. User taps subscription list → 2. Views subscribed subs → 3. Can subscribe/unsubscribe | Subreddit name, action (sub/unsub) | RedditAPIService.subscribe() → Update local list | Updated subscription list | GRDB subscription cache | Subscribed subreddits persist; can navigate to any subreddit |
| 10 | **Voting** | 1. User double-taps post (upvote) OR taps vote button → 2. Vote registers with haptic | Post/comment ID, vote direction (up/down/none) | RedditAPIService.vote() → Optimistic UI update → Error rollback | Vote state change with color + haptic | Vote state synced with Reddit | Double-tap upvotes; vote state persists; haptic feedback on vote |
| 11 | **Post Submission** (Pro) | 1. User taps compose → 2. Selects subreddit → 3. Types title + body → 4. Submits | Subreddit, title, body text, post type | Validation → RedditAPIService.submit() → Navigate to new post | New post appears in feed | None (server-side) | Post submits successfully; appears in subreddit feed |
| 12 | **Save/Share** | 1. User long-presses post → 2. Context menu shows → 3. Tap save or share | Post ID, action (save/share) | RedditAPIService.save() → Share sheet for sharing | Saved state / Share sheet | Save state synced with Reddit | Save persists across sessions; share opens system share sheet |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | Zero-Ad Feed | Skeleton loading | Show shimmer placeholder while feed loads | Automatic on load |
| 1.2 | Zero-Ad Feed | Pull to refresh | Pull down to refresh feed content | Vertical swipe down |
| 1.3 | Zero-Ad Feed | Infinite scroll | Auto-load more posts when scrolling near bottom | Scroll gesture |
| 1.4 | Zero-Ad Feed | Sort switching | Switch between hot/new/rising/top/controversial | Tap sort dropdown |
| 2.1 | Swipe Navigation | Preload buffer | Preload 3 posts ahead for zero-wait swiping | Automatic on index change |
| 2.2 | Swipe Navigation | Swipe velocity detection | Fast swipe = instant switch, slow swipe = rubber band | DragGesture velocity |
| 2.3 | Swipe Navigation | Swipe hint | Fade-in text hint "Swipe for next post" | Appears after 3s idle |
| 3.1 | Post Detail | Media viewer | Full-screen image/video viewer with pinch-to-zoom | Tap media |
| 3.2 | Post Detail | Markdown rendering | Render Reddit markdown (bold, italic, links, code, lists) | Automatic |
| 3.3 | Post Detail | Link preview | Show preview for external links with thumbnail | Tap link |
| 4.1 | Comment System | Collapse/expand | Tap comment to collapse/expand thread | Tap gesture |
| 4.2 | Comment System | Reply (Pro) | Reply to comments with text input | Tap reply button |
| 5.1 | Search | Trending topics | Show trending subreddits/topics on search page | Automatic on search tab |
| 5.2 | Search | Recent searches | Show and clear recent search history | Tap clear button |
| 6.1 | Dark Mode | System follow | Auto-switch based on system appearance setting | Automatic |
| 7.1 | User Auth | Token refresh | Auto-refresh expired OAuth tokens | Automatic on 401 response |
| 10.1 | Voting | Optimistic update | Show vote change immediately before API confirms | Immediate UI feedback |
| 10.2 | Voting | Haptic feedback | Light haptic on upvote, medium on downvote | Haptic engine |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Feed → Detail | Zero-Ad Feed | Post Detail | Post ID, subreddit name | User taps post card |
| Detail → Comments | Post Detail | Comment System | Post ID | User scrolls to comment section |
| Swipe → Preload | Swipe Navigation | Zero-Ad Feed | Current index, buffer threshold | Index within 5 of end |
| Auth → Feed | User Authentication | Zero-Ad Feed | Access token | User logs in |
| Auth → Vote | User Authentication | Voting | Access token | User attempts vote |
| Auth → Submit | User Authentication | Post Submission | Access token | User attempts post |
| Vote → Detail | Voting | Post Detail | Updated vote state | Vote changes on feed card |
| Search → Feed | Search | Zero-Ad Feed | Subreddit name or search query | User selects search result |
| Save → Account | Save/Share | User Authentication | Access token | User attempts save |

---

## Apple Design Guidelines Compliance

- **Navigation**: Uses NavigationStack (not deprecated NavigationView); swipe-back gesture preserved with custom back buttons
- **Tab Bar**: Standard TabView with 4 tabs (Home, Search, Inbox, Profile); uses system SF Symbols (outline variant)
- **Haptics**: UIImpactFeedbackGenerator for vote actions; UISelectionFeedbackGenerator for swipe transitions
- **Dark Mode**: Full dynamic color support using Color(adaptable:) and semantic colors; OLED black for dark mode
- **Dynamic Type**: All text uses SF Pro system font with relative font styles; supports user font size preferences
- **Safe Area**: All content respects safe area insets; bottom action bar positioned above home indicator
- **Privacy**: Minimal data collection; OAuth tokens in Keychain; no analytics tracking; anonymous browsing supported
- **App Store Review**: Reddit client category (News); no user-generated content hosting; OAuth2 for authentication; clear privacy policy

---

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), no UIKit except for gesture interop
- **Architecture**: MVVM + @Observable (iOS 17+)
- **Data**: GRDB.swift (SQLite) for caching + Keychain for tokens + UserDefaults for preferences
- **Networking**: Alamofire with async/await, OAuth2 interceptor, rate limiter, retry policy
- **Image Loading**: Nuke for async image loading and caching
- **Markdown**: MarkdownUI for Reddit content rendering
- **Concurrency**: Swift Concurrency (async/await, Actor)
- **Dependency Injection**: Manual DI (no Swinject, reduce dependencies)
- **Error Handling**: Typed throws + custom RedditError enum
- **Minimum iOS**: 17.0

---

## Module Structure

```
Flare/
├── FlareApp.swift
├── Models/
│   ├── Post.swift
│   ├── Comment.swift
│   ├── Subreddit.swift
│   ├── User.swift
│   ├── AuthToken.swift
│   └── FeedResult.swift
├── Services/
│   ├── RedditAPIService.swift
│   ├── AdFilterService.swift
│   ├── CacheService.swift
│   ├── AuthService.swift
│   ├── RateLimiter.swift
│   └── KeychainManager.swift
├── ViewModels/
│   ├── FeedViewModel.swift
│   ├── PostViewModel.swift
│   ├── CommentViewModel.swift
│   ├── SearchViewModel.swift
│   └── AuthViewModel.swift
├── Views/
│   ├── Feed/
│   │   ├── FeedView.swift
│   │   ├── PostCardView.swift
│   │   └── SwipeNavigationView.swift
│   ├── Post/
│   │   ├── PostDetailView.swift
│   │   └── MediaViewerView.swift
│   ├── Comments/
│   │   ├── CommentListView.swift
│   │   └── CommentCellView.swift
│   ├── Search/
│   │   └── SearchView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Auth/
│       └── LoginView.swift
├── Components/
│   ├── SkeletonView.swift
│   ├── VoteButton.swift
│   ├── MarkdownRenderer.swift
│   └── SortPickerView.swift
├── Extensions/
│   ├── Color+Theme.swift
│   ├── View+Modifiers.swift
│   └── Date+Format.swift
└── Resources/
    └── Assets.xcassets
```

---

## Data Flow Diagram (MANDATORY — Every Feature's Data Lifecycle)

### Feature 1: Zero-Ad Feed Browsing
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Opens app / selects subreddit / pulls to refresh     │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── FeedViewModel.loadInitialFeed()                      │
│      ├── Check CacheService.getCachedPosts()              │
│      ├── Call RedditAPIService.getFeed()                  │
│      ├── AdFilterService.filter() removes ads             │
│      └── CacheService.savePosts() with TTL=30min          │
│       │                                                   │
│  Model/Persistence                                        │
│  └── GRDB: posts table (id, title, author, score, etc.)   │
│      UserDefaults: currentSubreddit, sortType              │
│       │                                                   │
│  Display Output                                           │
│  └── FeedView renders PostCardView list                   │
│      SkeletonView during loading                          │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Post data available for SwipeNavigation, PostDetail  │
└───────────────────────────────────────────────────────────┘
```

### Feature 2: Swipe Navigation
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── DragGesture (left/right swipe on post card)          │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── SwipeNavigationView                                  │
│      ├── Detect direction + velocity + distance           │
│      ├── Threshold check: distance > 50pt OR vel > 200pt/s│
│      ├── PostNavigator: currentIndex += 1 or -= 1         │
│      └── Preload check: if index >= count-5, load more    │
│       │                                                   │
│  Model/Persistence                                        │
│  └── currentIndex in @State                               │
│      Preloaded posts in FeedViewModel.posts array          │
│       │                                                   │
│  Display Output                                           │
│  └── Spring animation (response: 0.35, dampingFraction: 0.8)│
│      Next/previous PostCardView slides in                  │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Triggers loadMorePosts() when near end of buffer     │
│      Passes current post to PostDetailView on tap         │
└───────────────────────────────────────────────────────────┘
```

### Feature 3: Post Detail
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Taps post card in FeedView                           │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── PostViewModel.loadPostDetail()                       │
│      ├── RedditAPIService.getPostComments()               │
│      ├── Parse post + comments from dual-listing response │
│      └── CacheService.savePostDetail()                    │
│       │                                                   │
│  Model/Persistence                                        │
│  └── GRDB: post_details table                             │
│       │                                                   │
│  Display Output                                           │
│  └── PostDetailView: title, author, time, content, media  │
│      MarkdownRenderer for text content                    │
│      MediaViewerView for images/videos                    │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Comments passed to CommentListView                  │
│      Vote state synced back to FeedViewModel              │
└───────────────────────────────────────────────────────────┘
```

### Feature 4: Comment System
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Scrolls to comments / taps collapse / votes / replies │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── CommentViewModel                                     │
│      ├── Parse recursive comment tree                     │
│      ├── Collapse/expand state management                 │
│      ├── Vote via RedditAPIService.vote()                 │
│      └── Reply via RedditAPIService.reply() (Pro)         │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Vote state in UserDefaults                           │
│      Collapse state in @State                             │
│       │                                                   │
│  Display Output                                           │
│  └── CommentListView with CommentCellView                 │
│      Indentation lines for depth levels                   │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Vote state synced with PostViewModel                 │
└───────────────────────────────────────────────────────────┘
```

### Feature 5: Search
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Types query in search bar / taps trending topic      │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── SearchViewModel                                      │
│      ├── Debounce input (300ms)                           │
│      ├── RedditAPIService.search()                        │
│      ├── AdFilterService.filter() on results              │
│      └── Save to recent searches                          │
│       │                                                   │
│  Model/Persistence                                        │
│  └── UserDefaults: recentSearches array                   │
│       │                                                   │
│  Display Output                                           │
│  └── SearchView: results list + trending + recent         │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Tapping result navigates to FeedView with subreddit  │
│      or PostDetailView for post results                   │
└───────────────────────────────────────────────────────────┘
```

### Feature 6: Dark Mode
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Long-press status bar / toggle in Settings           │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── SettingsViewModel                                    │
│      ├── Read/write theme preference                      │
│      └── Apply ColorScheme modifier to root view          │
│       │                                                   │
│  Model/Persistence                                        │
│  └── UserDefaults: themeMode (light/dark/system)          │
│       │                                                   │
│  Display Output                                           │
│  └── All views re-render with theme colors                │
│      Dark: OLED black (#000000), lighter orange (#FF6B35) │
│      Light: white (#FFFFFF), Reddit orange (#FF4500)      │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Theme applies globally to all views                  │
└───────────────────────────────────────────────────────────┘
```

### Feature 7: User Authentication
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Taps "Continue with Reddit" on login screen          │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── AuthViewModel                                        │
│      ├── Build OAuth2 authorize URL                       │
│      ├── Open Safari for user authorization               │
│      ├── Handle redirect URI with auth code               │
│      ├── Exchange code for access_token + refresh_token   │
│      └── Store tokens in Keychain                         │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Keychain: access_token, refresh_token                │
│      UserDefaults: username, isPro (placeholder)          │
│       │                                                   │
│  Display Output                                           │
│  └── Navigate to main FeedView                            │
│      Show username in profile tab                         │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Access token used by all authenticated API calls     │
│      Auto-refresh on 401 response                         │
└───────────────────────────────────────────────────────────┘
```

### Feature 8: Anonymous Browsing
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Taps "Browse without account" on login screen        │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── AuthViewModel                                        │
│      ├── Set isAnonymous = true                           │
│      ├── Use client_credentials grant for API access      │
│      └── Load popular/hot feed (no personalization)       │
│       │                                                   │
│  Model/Persistence                                        │
│  └── None (stateless browsing)                            │
│       │                                                   │
│  Display Output                                           │
│  └── FeedView with popular posts                          │
│      No user-specific content (no inbox, no subscriptions) │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Limited API: no voting, no posting, no saving        │
│      Can upgrade to authenticated later                   │
└───────────────────────────────────────────────────────────┘
```

### Feature 9: Voting
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Double-tap post (upvote) / tap vote button           │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── FeedViewModel / PostViewModel                        │
│      ├── Optimistic UI update (immediate color change)    │
│      ├── Haptic feedback (UIImpactFeedbackGenerator)      │
│      ├── RedditAPIService.vote(direction, postId)         │
│      └── Rollback on error                                │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Vote state synced with Reddit server                 │
│      Local optimistic state in ViewModel                  │
│       │                                                   │
│  Display Output                                           │
│  └── Upvote: orange highlight + up arrow filled           │
│      Downvote: blue highlight + down arrow filled         │
│      Score updates accordingly                            │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Vote state synced between FeedView and PostDetailView│
└───────────────────────────────────────────────────────────┘
```

---

## Implementation Flow

1. **Project Setup**: Create Xcode project with SwiftUI, configure SPM dependencies (Alamofire, GRDB, MarkdownUI, Nuke, KeychainAccess)
2. **Models Layer**: Define Post, Comment, Subreddit, User, AuthToken, FeedResult structs with Codable conformance
3. **Services Layer**: Implement RedditAPIService (OAuth2 + Alamofire), AdFilterService (multi-layer filtering), CacheService (GRDB), AuthService (token management), RateLimiter (100 QPM)
4. **Feed Feature**: FeedView + FeedViewModel + PostCardView + SwipeNavigationView + infinite scroll + skeleton loading
5. **Post Detail**: PostDetailView + PostViewModel + MarkdownRenderer + MediaViewerView
6. **Comments**: CommentListView + CommentViewModel + CommentCellView with tree structure
7. **Search**: SearchView + SearchViewModel + trending + recent searches
8. **Authentication**: LoginView + AuthViewModel + OAuth2 flow + Keychain token storage
9. **Dark Mode**: Color+Theme extension + SettingsView theme toggle + system appearance observer
10. **Settings**: SettingsView with account, theme, about, privacy policy, terms of use
11. **IAP Integration**: StoreKit2 for Pro subscription (monthly, yearly, lifetime)
12. **Polish**: Haptics, animations, edge cases, error handling, performance optimization

---

## UI/UX Design Specifications

### Color Scheme
```
Light Mode:
  Primary:     #FF4500 (Reddit Orange)
  Secondary:   #1A1A2E (Deep Navy)
  Background:  #FFFFFF (Pure White)
  Surface:     #F5F5F7 (Apple Gray)
  Text:        #1D1D1F (Apple Black)
  Text2:       #86868B (Apple Gray)
  Upvote:      #FF4500 (Orange)
  Downvote:    #7193FF (Blue)
  Success:     #34C759 (Green)
  Error:       #FF3B30 (Red)

Dark Mode:
  Primary:     #FF6B35 (Lighter Orange)
  Secondary:   #E0E0E0 (Light Gray)
  Background:  #000000 (Pure Black OLED)
  Surface:     #1C1C1E (Apple Dark)
  Text:        #F5F5F7 (Apple White)
  Text2:       #98989D (Apple Gray Dark)
  Upvote:      #FF6B35 (Lighter Orange)
  Downvote:    #6E9FFF (Lighter Blue)
  Success:     #30D158 (Green Dark)
  Error:       #FF453A (Red Dark)
```

### Typography
- SF Pro system font (all styles)
- Large Title: 34pt Bold — page titles
- Title 2: 22pt Bold — post titles
- Headline: 17pt Semibold — list items
- Body: 17pt Regular — content
- Subheadline: 15pt Regular — metadata
- Caption: 12pt Regular — timestamps

### Layout
- 8pt grid system (xs:4, sm:8, md:16, lg:24, xl:32, xxl:48)
- Post card corner radius: 12pt
- Navigation bar: ultraThinMaterial blur
- Tab bar: 4 tabs with SF Symbols (outline variant)
- Bottom action bar: fixed above safe area

### Animations
| Interaction | Animation | Duration | Curve |
|-------------|-----------|----------|-------|
| Post switch | Spring | 350ms | dampingFraction: 0.8 |
| Page transition | Slide + Fade | 300ms | easeInOut |
| Vote feedback | Scale + Color | 200ms | spring(response: 0.2) |
| Skeleton | Shimmer | 1.5s loop | easeInOut |
| Tab switch | Fade | 200ms | easeOut |
| Error toast | Slide from top | 300ms | easeOut |

---

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- Semantic naming, clear file structure
- Never add comments in code unless asked
- Apple native first: prioritize SwiftUI/Swift
- MVVM with @Observable (iOS 17+)
- Alamofire for networking, GRDB for persistence
- All UI components native SwiftUI (no third-party UI libraries)
- Manual DI (no Swinject)
- Swift Concurrency (async/await) throughout
- Typed error handling with RedditError enum
- Minimum 5 SPM dependencies: Alamofire, GRDB.swift, MarkdownUI, Nuke, KeychainAccess

---

## Build & Deployment Checklist

1. Xcode project configured with iOS 17.0 minimum deployment target
2. SPM dependencies added: Alamofire 5.x, GRDB 7.x, MarkdownUI 2.x, Nuke 12.x, KeychainAccess 4.x
3. App icon generated (gradient orange-red with white flame)
4. Bundle ID: com.zzoutuo.FlareForReddit
5. URL scheme registered: flare://auth (for OAuth callback)
6. Privacy Policy page deployed to GitHub Pages
7. Terms of Use page deployed to GitHub Pages
8. Support page deployed to GitHub Pages
9. App Store metadata prepared (keytextN.md)
10. IAP products configured in App Store Connect (monthly, yearly, lifetime)
11. Reddit API app registered at reddit.com/prefs/apps
12. TestFlight beta testing completed
