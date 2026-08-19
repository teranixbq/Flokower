# 🎨 Flokower Design System

## 🌈 Color Palette

### Light Mode (Default)

#### Core Colors
```dart
// Background Colors
const background = Color(0xFFF7F7F7);        // Off-white - main screen bg
const surface = Color(0xFFF8F8F8);           // Light gray - cards/panels
const card = Color(0xFFFFFFFF);               // White - individual cards

// Text Colors  
const primaryText = Color(0xFF1A1A1A);       // Near-black - main content
const secondaryText = Color(0xFF888888);     // Medium gray - subtitles/hints
const placeholder = Color(0xFFCCCCCC);       // Light gray - input hints
const disabledText = Color(0xFFCCCCCC);      // Disabled state text

// Borders & Dividers
const border = Color(0xFFEEEEEE);            // Light gray borders
const divider = Color(0xFFE8E8E8);           // Silver dividers
const outline = Color(0xFF0FAC93);           // Teal outlines (primary)

// Interactive States
const primary = Color(0xFF0FAC93);           // Teal - primary actions (logo color)
const primaryHover = Color(0xFF0D9B84);      // Darker teal - hover
const primaryTextWhite = Color(0xFFFFFFFF);  // White on teal backgrounds

// Status Colors (Accent)
const success = Color(0xFF2D8B4E);           // Green - success states
const successLight = Color(0xFFE8F5ED);      // Light green bg
const warning = Color(0xFFC67A2E);           // Orange - warnings
const warningLight = Color(0xFFFDF3E7);      // Light orange bg
const error = Color(0xFFC44536);             // Red - errors/alerts
const errorLight = Color(0xFFFDECEA);        // Light red bg
const info = Color(0xFF3A6EA5);              // Blue - info states
const infoLight = Color(0xFFEBF2FA);         // Light blue bg
const neutral = Color(0xFF888888);           // Medium gray - neutral states
```

#### Usage Guidelines

**Backgrounds:**
- `background` → Main screen surfaces (offWhite #F7F7F7)
- `surface` → Cards, panels, elevated sections
- `card` → Individual item cards (white)

**Text Hierarchy:**
- `primaryText` → Headlines, body text, labels (near-black #1A1A1A)
- `secondaryText` → Descriptions, captions, metadata (medium gray #888888)
- `placeholder` → Empty input fields, loading states (light gray #CCCCCC)
- `disabledText` → Non-interactive elements

**Borders:**
- `border` → Card borders, input outlines (#EEEEEE)
- `divider` → Section separators, list dividers (silver #E8E8E8)
- `outline` → Button outlines, active states (teal #0FAC93)

**Interactive Elements:**
- `primary` → Primary buttons, FABs, selected states (teal #0FAC93)
- `primaryHover` → Hover effects (darker teal #0D9B84)
- `success`, `warning`, `error`, `info` → Status badges, alerts, validators

---

### Dark Mode (Optional Enhancement)

```dart
// Background Colors
const backgroundDark = Color(0xFF121212);    // Dark gray - main screens
const surfaceDark = Color(0xFF1E1E1E);       // Slightly lighter - cards
const cardDark = Color(0xFF242424);          // Dark cards

// Text Colors
const primaryTextDark = Color(0xFFFFFFFF);   // White - main content
const secondaryTextDark = Color(0xFFB0B0B0); // Light gray - subtitles
const placeholderDark = Color(0xFF666666);   // Medium gray - hints

// Borders
const borderDark = Color(0xFF333333);        // Dark borders
const dividerDark = Color(0xFF2A2A2A);       // Subtle dividers

// Interactive
const primaryDark = Color(0xFF0FAC93);       // Teal buttons (same as light)
const primaryHoverDark = Color(0xFF0D9B84);  // Darker teal hover
```

---

## 🔤 Typography

### Font Family

**Primary Font:** Inter (Google Fonts)

**Fallback Stack:**
```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 
             Roboto, Helvetica, Arial, sans-serif;
```

### Type Scale

#### Headlines

```dart
HeadlineLarge: {
  fontFamily: 'Inter',
  fontSize: 32,
  fontWeight: FontWeight.w600,        // SemiBold
  letterSpacing: -0.5,
  height: 1.2,                        // Tight line height
}

HeadlineMedium: {
  fontFamily: 'Inter',
  fontSize: 24,
  fontWeight: FontWeight.w500,        // Medium
  letterSpacing: 0,
  height: 1.3,
}

HeadlineSmall: {
  fontFamily: 'Inter',
  fontSize: 20,
  fontWeight: FontWeight.w500,        // Medium
  letterSpacing: 0,
  height: 1.4,
}
```

#### Body Text

```dart
BodyLarge: {
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.w400,        // Regular
  letterSpacing: 0,
  height: 1.5,                        // Comfortable reading
}

BodyMedium: {
  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w400,        // Regular
  letterSpacing: 0,
  height: 1.4,
}

BodySmall: {
  fontFamily: 'Inter',
  fontSize: 12,
  fontWeight: FontWeight.w500,        // Medium (for emphasis)
  letterSpacing: 0,
  height: 1.4,
}
```

#### Buttons & Capsules

```dart
ButtonText: {
  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w500,        // Medium
  letterSpacing: 0.5,                 // Uppercase feel
  textTransform: uppercase,           // Optional for buttons
}

Caption: {
  fontFamily: 'Inter',
  fontSize: 11,
  fontWeight: FontWeight.w500,        // Medium
  letterSpacing: 0.3,
  height: 1.3,
}
```

### Usage Guidelines

**Headlines:**
- `HeadlineLarge` → Page titles, dashboard metrics
- `HeadlineMedium` → Section headers, card titles
- `HeadlineSmall` → Secondary headings, form section titles

**Body:**
- `BodyLarge` → Main content, longer text blocks
- `BodyMedium` → Standard lists, descriptions
- `BodySmall` → Captions, metadata, small print

**Buttons:**
- All button text uses `ButtonText` style
- Consider all-caps for stronger emphasis

---

## 📏 Spacing System

### Base Unit: 8px Grid

```dart
class AppSpacing {
  static const xs = 4.0;    // Extra small - micro间距
  static const sm = 8.0;    // Small - standard padding
  static const md = 16.0;   // Medium - card padding
  static const lg = 24.0;   // Large - section spacing
  static const xl = 32.0;   // Extra large - page margins
  
  // Component-specific
  static const buttonPaddingHorizontal = 24.0;
  static const buttonPaddingVertical = 12.0;
  static const inputPadding = 16.0;
  static const cardPadding = 16.0;
  static const bentoGridGap = 16.0;
}
```

### Responsive Breakpoints

```dart
class AppBreakpoints {
  static const mobileMin = 320.0;
  static const mobileMax = 767.0;
  static const tabletMin = 768.0;
  static const tabletMax = 1023.0;
  static const desktopMin = 1024.0;
  
  // Column counts
  static const mobileColumns = 1;
  static const tabletColumns = 2;
  static const desktopColumns = 4;
}
```

---

## 🔘 Border Radius

```dart
class AppBorderRadius {
  static const none = Radius.zero;
  static const xs = Radius.circular(4);    // Micro elements
  static const sm = Radius.circular(8);    // Buttons, chips
  static const md = Radius.circular(12);   // Cards, dialogs (default)
  static const lg = Radius.circular(16);   // Large cards, overlays
  static const xl = Radius.circular(24);   // Special cards
  static const full = Radius.circular(9999); // Pills, avatars
}
```

### Usage Guidelines

- **Cards**: `md` (12px) - Clean but not too rounded
- **Buttons**: `sm` (8px) or `full` for pill shapes
- **Inputs**: `sm` (8px) - Modern feel
- **Images**: Match container radius
- **Overlays/Modals**: `lg` (16px) - Softer appearance

---

## 🎭 Component Styles

### Cards (Bento Grid)

```dart
class BentoCardStyle {
  static const backgroundColor = AppColors.surface;
  static const borderRadius = AppBorderRadius.md;
  static const padding = EdgeInsets.all(16.0);
  static const elevation = 0.0;              // Flat design
  static const borderSide = BorderSide(
    color: AppColors.border,
    width: 1.0,
  );
  static const boxShadow = [
    BoxShadow(
      color: Color(0x0D000000),              // Very subtle (5% opacity)
      offset: Offset(0, 2),
      blurRadius: 4,
    )
  ];
}
```

### Buttons

**Primary Button (Filled):**
```dart
PrimaryButtonStyle: {
  backgroundColor: AppColors.primary,
  foregroundColor: AppColors.primaryTextWhite,
  borderRadius: AppBorderRadius.sm,
  minWidth: 120,
  height: 48,
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  textStyle: AppFonts.buttonText,
  shadowColor: Color(0x33000000),           // 20% opacity shadow
  elevation: 2,
}
```

**Outlined Button:**
```dart
OutlinedButtonStyle: {
  backgroundColor: Colors.transparent,
  borderColor: AppColors.outline,
  borderWidth: 1.5,
  borderRadius: AppBorderRadius.sm,
  minWidth: 120,
  height: 48,
  textColor: AppColors.primary,
  textStyle: AppFonts.buttonText,
}
```

**Disabled State:**
```dart
DisabledButtonStyle: {
  opacity: 0.5,
  cursor: CursorName.notAllowed,
}
```

### Inputs

**Text Field:**
```dart
InputFieldStyle: {
  borderRadius: AppBorderRadius.sm,
  borderSide: BorderSide(
    color: AppColors.border,
    width: 1.0,
  ),
  focusedBorder: BorderSide(
    color: AppColors.primary,
    width: 1.5,
  ),
  fillColor: AppColors.background,
  enabledFillColor: AppColors.surface,
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  textStyle: AppFonts.bodyMedium,
  hintText: AppColors.placeholder,
  hintStyle: TextStyle(
    color: AppColors.placeholder,
    fontStyle: FontStyle.italic,
  ),
}
```

### Badges

**Status Badge:**
```dart
BadgeStyle: {
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  borderRadius: AppBorderRadius.full,
  textStyle: AppFonts.caption.copyWith(
    fontWeight: FontWeight.w600,
  ),
  
  // Variant colors
  success: {
    backgroundColor: AppColors.successLight,
    textColor: AppColors.success,
  },
  warning: {
    backgroundColor: AppColors.warningLight,
    textColor: AppColors.warning,
  },
  error: {
    backgroundColor: AppColors.errorLight,
    textColor: AppColors.error,
  },
  neutral: {
    backgroundColor: AppColors.neutral.withOpacity(0.1),
    textColor: AppColors.neutral,
  }
}
```

---

## 📐 Layout Patterns

### Bento Grid Layout

```dart
BentoGridConfig: {
  minItemWidth: 280,
  minItemHeight: 120,
  maxWidth: 1200,
  gap: 16,
  padding: 24,
  columns: {
    mobile: 1,
    tablet: 2,
    desktop: 4,
  },
  aspectRatios: {
    metric: 1.618,  // Golden ratio for main metrics
    chart: 1.0,     // Square for charts
    tall: 0.618,    // Vertical for stats
  }
}
```

### Bottom Navigation

```dart
BottomNavConfig: {
  itemCount: 4,
  height: 64,
  labelPosition: LabelPosition.belowIcon,
  iconSize: 24,
  labelStyle: AppFonts.bodySmall,
  activeColor: AppColors.primary,
  inactiveColor: AppColors.secondaryText,
  selectedItemColor: AppColors.primary,
  unselectedLabelBehavior: LabelElementState.hidden,
}
```

---

## 🎬 Animations

### Durations

```dart
AnimationDurations: {
  fast: Duration(milliseconds: 200),    // Micro-interactions
  normal: Duration(milliseconds: 300),  // Standard transitions
  slow: Duration(milliseconds: 500),    // Complex animations
  verySlow: Duration(milliseconds: 700),// Heavy animations
}
```

### Easing

```dart
AnimationCurves: {
  default: Curves.easeInOut,
  bounce: Curves.bounceOut,
  flutter: Curves.elasticOut,
  smooth: Curves.ease,
  sharp: Curves.fastOutSlowIn,
}
```

---

## 🔄 Theme Configuration

### Light Theme (Default)

```dart
final flokowerLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  
  // Colors
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  cardColor: AppColors.card,
  
  // Typography
  fontFamily: 'Inter',
  textTheme: TextTheme(
    headlineLarge: AppFonts.headlineLarge,
    headlineMedium: AppFonts.headlineMedium,
    headlineSmall: AppFonts.headlineSmall,
    bodyLarge: AppFonts.bodyLarge,
    bodyMedium: AppFonts.bodyMedium,
    bodySmall: AppFonts.bodySmall,
    labelLarge: AppFonts.buttonText,
    labelSmall: AppFonts.caption,
  ),
  
  // Component themes
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    titleTextStyle: AppFonts.headlineSmall,
  ),
  
  cardTheme: CardTheme(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorderRadius.md,
      side: BorderSide(color: AppColors.border),
    ),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.primaryTextWhite,
      minimumSize: Size(120, 48),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.sm,
      ),
    ),
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: AppBorderRadius.sm,
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppBorderRadius.sm,
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppBorderRadius.sm,
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
  ),
  
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.primaryTextWhite,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorderRadius.full,
    ),
  ),
);
```

---

## 📱 Platform Adaptations

### Mobile (iOS/Android)

- Use native safe area insets
- Touch targets minimum 48x48dp
- Pull-to-refresh for lists
- Swipe gestures where appropriate

### Tablet

- Two-column layouts for bento grid
- Larger touch targets
- Side-by-side detail views

### Desktop (Web/Desktop app)

- Hover states for interactive elements
- Keyboard navigation support
- Cursor changes on hover (pointer, not-allowed)

---

## ♿ Accessibility

### Contrast Ratios

All color combinations must meet WCAG AA standards:

- **Normal text**: Minimum 4.5:1 contrast ratio
- **Large text** (18pt+): Minimum 3:1 contrast ratio
- **UI components**: Minimum 3:1 against background

### Focus Indicators

```dart
FocusWidgetStyle: {
  outlineColor: AppColors.primary,
  outlineWidth: 2,
  borderRadius: AppBorderRadius.sm,
  offset: 2,
}
```

### Screen Reader Support

- Provide meaningful semantic labels
- Ensure logical reading order
- Announce status changes dynamically
- Use proper heading hierarchy

---

## 🚀 Implementation Guide

### Using Design Tokens in Flutter

```dart
// Import tokens
import 'package:flokower/shared/theme/app_colors.dart';
import 'package:flokower/shared/theme/app_fonts.dart';
import 'package:flokower/shared/theme/app_spacing.dart';

// Use in widget
Container(
  color: AppColors.surface,
  padding: AppSpacing.cardPadding,
  child: Text(
    'Hello Flokower',
    style: AppFonts.headlineMedium,
  ),
)
```

### Creating Custom Components

```dart
class CustomBentoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorderRadius.md,
          border: Border.all(color: AppColors.border),
          boxShadow: BentoCardStyle.boxShadow,
        ),
        padding: AppSpacing.cardPadding,
        child: child,
      ),
    );
  }
}
```

---

*Last Updated: 2024-01-XX*  
*Maintained by: Flokower Design Team*  
*Version: 1.0*
