# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | Flare-for-Reddit |
| **Git URL** | git@github.com:asunnyboy861/Flare-for-Reddit.git |
| **Repo URL** | https://github.com/asunnyboy861/Flare-for-Reddit |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/Flare-for-Reddit/ | ✅ Active |
| Support | https://asunnyboy861.github.io/Flare-for-Reddit/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/Flare-for-Reddit/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/Flare-for-Reddit/terms.html | ✅ Active |

## Repository Structure

```
Flare-for-Reddit/
├── Flare for Reddit/                    # iOS App Source Code
│   ├── Flare for Reddit.xcodeproj/      # Xcode Project
│   ├── Flare for Reddit/                # Swift Source Files
│   │   ├── Models/
│   │   ├── Extensions/
│   │   ├── Services/
│   │   ├── Components/
│   │   ├── ViewModels/
│   │   ├── Views/
│   │   │   ├── Feed/
│   │   │   ├── Post/
│   │   │   ├── Comments/
│   │   │   ├── Search/
│   │   │   ├── Settings/
│   │   │   ├── Auth/
│   │   │   ├── Contact/
│   │   │   └── Paywall/
│   │   ├── ContentView.swift
│   │   └── Flare_for_RedditApp.swift
│   └── Assets.xcassets/
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md
├── capabilities.md
├── icon.md
├── price.md
└── nowgit.md
```
