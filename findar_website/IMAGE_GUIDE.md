# 📸 Image Placement Guide for Findar Website

## Directory Structure

Create these folders in your project:

```
findar_website/
└── public/
    ├── screenshots/          # App screenshots
    │   ├── hero-mockup.png  # Main hero phone mockup
    │   ├── search.png       # Advanced Search feature
    │   ├── favorites.png    # Save Favorites feature
    │   ├── listings.png     # Property Listings feature
    │   ├── notifications.png # Real-time Updates feature
    │   ├── contact.png      # Direct Contact feature
    │   └── security.png     # Verified Listings feature
    │
    ├── logos/               # Company and partner logos
    │   └── findar-logo.png
    │
    └── team/               # Team member photos (optional)
        └── placeholder.png
```

## 📱 Screenshot Requirements

### Hero Section - Main Mockup
- **File**: `public/screenshots/hero-mockup.png`
- **Size**: 1080 x 2340px (9:19 aspect ratio)
- **Format**: PNG with transparency preferred
- **Content**: App home screen or main interface
- **Location in code**: `src/components/Hero.tsx` line 29-33

### Feature Screenshots (All Features)
Each feature needs a screenshot showing that specific functionality:

1. **Advanced Search** - `public/screenshots/search.png`
   - Show the search interface with filters
   - Size: 1080 x 2340px

2. **Save Favorites** - `public/screenshots/favorites.png`
   - Show saved/favorited properties
   - Size: 1080 x 2340px

3. **Property Listings** - `public/screenshots/listings.png`
   - Show property listing creation or grid
   - Size: 1080 x 2340px

4. **Real-time Updates** - `public/screenshots/notifications.png`
   - Show notification screen
   - Size: 1080 x 2340px

5. **Direct Contact** - `public/screenshots/contact.png`
   - Show messaging or contact interface
   - Size: 1080 x 2340px

6. **Verified Listings** - `public/screenshots/security.png`
   - Show verification badges or secure interface
   - Size: 1080 x 2340px

**Location in code**: `src/components/Features.tsx` lines 103-115

## 🎨 Image Tips

### Taking Screenshots from Your Flutter App:
1. Open your Flutter app in emulator or device
2. Navigate to each feature screen
3. Take screenshots (Ctrl+S in Android Studio, or device screenshot)
4. Export as PNG

### Image Optimization:
- Use tools like TinyPNG to compress images
- Keep file sizes under 500KB for fast loading
- Use PNG for UI screenshots (better quality)
- Use WebP format for even smaller sizes (modern browsers)

### Quick Creation with Placeholders:
If you don't have screenshots yet, you can:
1. Use Figma/Sketch mockups
2. Take screenshots from similar apps temporarily
3. Use placeholder generators like https://placeholder.com/

## 📝 How to Add Images to Code

### Step 1: Place Images
Copy your images to `findar_website/public/screenshots/`

### Step 2: Images Will Auto-Update
Once you place images in the correct folders, they'll automatically appear on the website!

## 🔄 Current Placeholder Behavior

Right now the website shows:
- **Hero**: Gray placeholder with "App Screenshot Placeholder" text
- **Features Slider**: Gradient backgrounds with icons

Once you add the images, these will be replaced with your actual screenshots!

## ⚡ Pro Tip

The `public` folder in Next.js is special - anything inside it can be accessed directly in your code using `/filename.png` (no need for `public/` in the path).

Example:
- File location: `public/screenshots/search.png`
- Use in code: `<Image src="/screenshots/search.png" />`
