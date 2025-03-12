# Modern Flutter Notification System
A highly customizable, animated notification system for Flutter applications with support for success, error, warning, and info messages.

![Notification Types Preview]

## Features
- 🎯 4 notification types: Success, Error, Warning, Info
- 🎨 Fully customizable appearance
- ✨ Smooth animations with slide and fade effects
- 🔄 Linear progress indicator (optional)
- 👆 Multiple dismiss actions:
  - Swipe to dismiss
  - Tap to dismiss 
  - Auto-dismiss with timer
- 📱 Safe area aware
- 🎯 Singleton pattern to prevent notification overlap
- 🔍 Debug mode support

## Installation
Add this notification system to your project by copying the `notification_service.dart` file to your lib folder.

## Basic Usage

### 1. Initialize the Service
Initialize the notification service in your main app widget:
```dart
@override
void initState() {
  super.initState();
  NotificationService.initialize(context);
}
```

### 2. Show Notifications
```dart
// Success message
NotificationService.showSuccess(
  'Successfully saved!',
  duration: Duration(seconds: 3),
);

// Error message
NotificationService.showError(
  'Something went wrong!',
  duration: Duration(seconds: 3),
);

// Warning message
NotificationService.showWarning(
  'Low storage space',
  duration: Duration(seconds: 3),
);

// Info message
NotificationService.showInfo(
  'New update available',
  duration: Duration(seconds: 3),
);
```

## Advanced Usage

### Custom Configuration
You can customize the notification appearance using NotificationConfig:

```dart
NotificationService.showSuccess(
  'Custom styled notification',
  config: NotificationConfig(
    backgroundColor: Colors.green.shade50,
    borderColor: Colors.green.shade200,
    textColor: Colors.green.shade900,
    iconColor: Colors.green.shade700,
    showProgressIndicator: true,
    borderRadius: 12.0,
    padding: EdgeInsets.all(16),
    position: NotificationPosition.top,
    animationDuration: Duration(milliseconds: 300),
    dismissDirection: DismissDirection.up,
    elevation: 2.0,
  ),
);
```

### Global Configuration
Set default configuration for all notifications:

```dart
NotificationService.setGlobalConfig(
  NotificationConfig(
    showProgressIndicator: true,
    position: NotificationPosition.bottom,
    animationDuration: Duration(milliseconds: 400),
  ),
);
```

### Custom Notification Builder
Create completely custom notifications using builder:

```dart
NotificationService.show(
  builder: (context, animation) => YourCustomWidget(
    animation: animation,
    // ... your custom properties
  ),
  duration: Duration(seconds: 3),
);
```

## Configuration Options

### NotificationConfig Properties

| Property | Type | Description |
|----------|------|-------------|
| backgroundColor | Color? | Background color of notification |
| borderColor | Color? | Border color of notification |
| textColor | Color? | Text color of notification |
| iconColor | Color? | Icon color of notification |
| showProgressIndicator | bool | Show/hide progress indicator |
| borderRadius | double | Corner radius of notification |
| padding | EdgeInsets | Internal padding of notification |
| position | NotificationPosition | Top or bottom position |
| animationDuration | Duration | Duration of show/hide animations |
| dismissDirection | DismissDirection | Swipe direction to dismiss |
| elevation | double | Shadow elevation of notification |
| icon | IconData? | Custom icon for notification |
| progressIndicatorColor | Color? | Color of progress indicator |
| progressIndicatorHeight | double | Height of progress indicator |
| maxWidth | double? | Maximum width of notification |
| margin | EdgeInsets? | External margin of notification |

### NotificationPosition Options
- `NotificationPosition.top`
- `NotificationPosition.bottom`

### DismissDirection Options
- `DismissDirection.up`
- `DismissDirection.down`
- `DismissDirection.horizontal`

## Example Scenarios

### Long Message Handling
```dart
NotificationService.showInfo(
  'This is a very long notification message that will wrap to multiple lines automatically while maintaining proper layout and spacing.',
  duration: Duration(seconds: 5),
);
```

### Custom Success with Progress
```dart
NotificationService.showSuccess(
  'Upload completed!',
  config: NotificationConfig(
    showProgressIndicator: true,
    progressIndicatorColor: Colors.green.shade300,
    progressIndicatorHeight: 2,
  ),
);
```

### Warning with Custom Position
```dart
NotificationService.showWarning(
  'Battery low',
  config: NotificationConfig(
    position: NotificationPosition.bottom,
    margin: EdgeInsets.only(bottom: 20),
  ),
);
```

## Debug Mode
Enable debug mode to see helpful logs:
```dart
NotificationService.debugMode = true;
```

## Best Practices
1. Initialize the service early in your app lifecycle
2. Use appropriate notification types for different scenarios
3. Keep messages concise and clear
4. Consider user interaction patterns when setting position
5. Use consistent styling across your app
6. Handle orientation changes appropriately

## Notes
- Only one notification is shown at a time
- New notifications replace existing ones
- Notifications respect safe areas on all devices
- All customization options are optional with sensible defaults

## Contributing
Feel free to contribute to this project by:
1. Reporting bugs
2. Suggesting new features
3. Creating pull requests

## License
This notification system is open-source and available under the MIT License.