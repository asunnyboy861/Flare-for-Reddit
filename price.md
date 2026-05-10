# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group
- **Group Name**: Flare Pro
- **Group ID**: FlarePro

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: Flare Pro Monthly
- **Product ID**: `com.zzoutuo.FlareForReddit.pro.monthly`
- **Price**: $1.99 per month
- **Display Name**: Flare Pro Monthly
- **Description**: Unlimited browsing + interactions
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: Flare Pro Yearly
- **Product ID**: `com.zzoutuo.FlareForReddit.pro.yearly`
- **Price**: $9.99 per year (58% savings vs monthly)
- **Display Name**: Flare Pro Yearly
- **Description**: Unlimited browsing + interactions
- **Localization**: English (US)

### 3. Lifetime Purchase
- **Reference Name**: Flare Pro Lifetime
- **Product ID**: `com.zzoutuo.FlareForReddit.pro.lifetime`
- **Price**: $29.99 one-time
- **Display Name**: Flare Pro Lifetime
- **Description**: Forever unlimited access
- **Localization**: English (US)

## Free Tier Features
- Browse Reddit posts (Hot/New/Rising)
- Swipe navigation (core feature)
- Zero-ad browsing
- Dark mode
- Search functionality
- Anonymous browsing mode
- Daily browsing limit: 200 post loads/day

## Pro Features (Unlocked by any subscription)
- Unlimited browsing (no daily limit)
- Comment viewing and interaction (reply/vote)
- Post submission (text/link)
- Multi-account support
- Custom gestures
- Offline reading
- Widget support
- Custom themes
- Keyword filtering

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to monthly)

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Free trial terms included
- [ ] Restore purchases functionality implemented

## StoreKit 2 Implementation Plan
- PurchaseManager.swift using StoreKit 2 API
- Product fetching: Product.products(for:)
- Purchase flow: product.purchase()
- Status tracking: Transaction.updates
- Restore: AppStore.sync()
- Paywall UI: SwiftUI sheet with clear pricing, no dark patterns
