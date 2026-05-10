# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- "订阅" / "会员" / "premium" / "购买" → In-App Purchase required
- Reddit API network calls → Outgoing Network Connections required
- OAuth2 redirect (flare://auth) → URL Scheme registration required
- Token storage → Keychain access required

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Outgoing Network Connections | ✅ Configured | Default for iOS apps |
| URL Scheme (flare://auth) | ✅ Configured | Info.plist URL types |
| Keychain Access | ✅ Configured | KeychainAccess SPM dependency |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| In-App Purchase | ⏳ Pending | 1. Open Xcode → Signing & Capabilities → + Capability → In-App Purchase; 2. In App Store Connect, create IAP products: com.zzoutuo.FlareForReddit.pro.monthly ($1.99/mo), com.zzoutuo.FlareForReddit.pro.yearly ($9.99/yr), com.zzoutuo.FlareForReddit.pro.lifetime ($29.99); 3. Sign Paid Applications Agreement in App Store Connect |
| Reddit API App | ⏳ Pending | 1. Visit https://www.reddit.com/prefs/apps; 2. Create "installed app" type; 3. Set redirect URI to flare://auth; 4. Copy client_id and client_secret into app configuration |

## No Configuration Needed
- iCloud: No sync feature in MVP
- Push Notifications: No push notifications in MVP
- HealthKit: Not a health app
- Location Services: No location features
- Apple Watch: No watch companion
- Camera/Photo Library: No camera features
- Background Modes: No background refresh in MVP
- Siri: No Siri integration

## Verification
- Build succeeded after configuration: Pending verification
- All entitlements correct: Pending verification
