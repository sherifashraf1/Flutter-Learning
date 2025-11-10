# Todo Task App - Flutter

A **Flutter todo task management application** that allows users to create, manage, and organize their tasks. Built with modern Flutter practices including state management, local persistence, and adaptive theming.

---

## Features

### 📝 Todo Task Management
- **Create Tasks**: Add new tasks with title and description using a reusable bottom sheet
- **View Tasks**: Display all tasks in a scrollable list with title and description
- **Edit Tasks**: Tap any task to view/edit details, update title, description, and completion status
- **Delete Tasks**: Remove tasks with a confirmation dialog for safe deletion
- **Complete Tasks**: Toggle task completion with visual feedback (strikethrough and gray color)
- **Local Persistence**: All tasks are saved locally using Hive database and persist across app restarts
- **Empty State**: Handles empty state when no tasks exist
- **State Management**: Uses Riverpod for reactive UI updates

### ⚙️ Settings & Theming
- **Adaptive Theme**: Light/dark mode support with theme persistence
- **Material 3**: Modern Material Design 3 implementation
- **Custom Color Schemes**: Beautiful color schemes for both light and dark themes
- **Custom Fonts**: Raleway and RobotoSlab font families
- **Settings Screen**: Easy theme switching via settings screen

---

## Tech Stack

- **Flutter SDK**: ^3.9.2
- **State Management**: `flutter_riverpod` ^3.0.3
- **Local Storage**: `hive` ^2.2.3, `hive_flutter` ^1.1.0
- **Theming**: `adaptive_theme` ^3.7.2
- **Environment Variables**: `flutter_dotenv` ^6.0.0

---

## Project Structure

```
lib/
├── models/
│   └── todo/          # Todo data model
├── providers/          # Riverpod providers for state management
├── router/             # App routing configuration
├── screens/
│   ├── todo/          # Todo task screens
│   │   ├── tasks_screen.dart
│   │   ├── task_details_screen.dart
│   │   └── settings_screen.dart
│   └── home/          # Home screen with tabs
├── shared/             # Shared widgets (DataStateWidget, etc.)
├── theme/              # Theme configuration
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   └── app_theme.dart
└── widgets/
    └── todo/          # Todo-specific widgets
        ├── task_card.dart
        └── reusable_bottom_sheet.dart
```

---

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

---

## How to Use

### Adding a Task
1. Tap the **floating action button** (FAB) on the tasks screen
2. Enter task **title** and **description** in the bottom sheet
3. Tap **Save** to add the task

### Editing a Task
1. Tap on any task card to open the **task details screen**
2. Modify the title, description, or completion status
3. Tap **Save Changes** to update the task

### Completing a Task
1. Tap the **checkbox** on a task card, or
2. Open task details and toggle the **"Mark as completed"** checkbox

### Deleting a Task
1. Use the delete action on a task card
2. Confirm deletion in the dialog

### Changing Theme
1. Navigate to the **Settings** tab
2. Toggle the **Dark Mode** switch
3. Theme preference is automatically saved

---

## Key Features Explained

### Task Management
- **CRUD Operations**: Full Create, Read, Update, Delete functionality
- **Local Persistence**: Tasks are stored locally using Hive, no internet required
- **Visual Feedback**: Completed tasks show strikethrough text and gray color
- **Reusable Components**: Bottom sheet widget is customizable and reusable

### State Management
- **Riverpod**: Modern state management solution for reactive UI
- **Provider Pattern**: Clean separation of business logic and UI
- **Auto-dispose**: Providers automatically clean up when not needed

### Theming
- **Adaptive Theme**: Automatically adapts to system theme or user preference
- **Persistent**: Theme choice is saved and restored on app restart
- **Material 3**: Latest Material Design guidelines

---

## License

This project is for learning purposes.
