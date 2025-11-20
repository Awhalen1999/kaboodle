# Lottie Animations

This folder contains Lottie animation files (`.json`) for the Kaboodle app.

## What is Lottie?

Lottie is a library that renders Adobe After Effects animations in real-time. Animations are exported as small JSON files that can be rendered at any size without loss of quality.

## How to Add Animations

1. **Find an animation** from [LottieFiles.com](https://lottiefiles.com) (thousands of free animations)
2. **Download the JSON file** (not the GIF or MP4)
3. **Add it to this folder** with a descriptive name
4. **Use it in code** with `Lottie.asset('assets/lottie/your-file.json')`

## File Naming Conventions

Use descriptive, lowercase names with underscores:
- ✅ `loading_suitcase.json`
- ✅ `success_checkmark.json`
- ✅ `empty_state_travel.json`
- ❌ `animation1.json`
- ❌ `LottieFile.json`

## Common Use Cases

### Loading States
```dart
Lottie.asset(
  'assets/lottie/loading_suitcase.json',
  width: 150,
  height: 150,
)
```

### Success Animations
```dart
Lottie.asset(
  'assets/lottie/success_checkmark.json',
  width: 100,
  height: 100,
  repeat: false, // Play once
)
```

### Empty States
```dart
Lottie.asset(
  'assets/lottie/empty_state_travel.json',
  width: 200,
  height: 200,
)
```

## Tips

- Keep files under 100KB for best performance
- Use looping for loading states: `repeat: true`
- Use one-shot for success/error states: `repeat: false`
- Preview animations on LottieFiles before downloading
- Test on both light and dark mode if your animation has colors

## Resources

- [LottieFiles.com](https://lottiefiles.com) - Free animations
- [Lottie Flutter Package](https://pub.dev/packages/lottie) - Documentation
