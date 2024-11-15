# Media App

The Media App is a Flutter application that allows users to view, like, and upload media (images or videos). It includes features for toggling between light and dark themes, viewing a list of media items, liking/unliking them, and uploading new media using a pre-signed URL mechanism.

---

## Features

1. **View Media List**  
   - Displays a list of media items fetched from an API.
   - Each item includes an image, like count, and a like/unlike button.

2. **Like and Unlike Media**  
   - Users can like or unlike a media item, and the like count updates in real-time.

3. **Upload Media**  
   - Allows users to upload images from their device.
   - Uses pre-signed URLs to securely upload files to a cloud storage service.

4. **Theme Toggle**  
   - Users can switch between light and dark modes dynamically.

---

## Folder Structure

```plaintext
lib/
├── main.dart                 # Entry point of the application
├── screens/
│   └── media_app_screen.dart # Main screen displaying the media app features
├── models/
│   └── media_item.dart       # Data model for media items
├── services/
│   └── api_service.dart      # Handles API calls for fetching, liking, and uploading media
├── widgets/
│   ├── media_card.dart       # Widget for displaying individual media items
├── utils/
│   └── theme_toggle.dart     # Utility functions for app-wide theme management
```
## How to Run the App
### Prerequisites
1. **Flutter SDK** installed on your system.  
   [Get Flutter SDK](https://docs.flutter.dev/get-started/install)
2. A compatible code editor, such as **Visual Studio Code** or **Android Studio**.
3. A connected device or emulator to run the app.

### Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Awadly/fluttermedia.git
   cd myapp
2. **Install Dependencies**
   ```bash
   flutter pub get
   ```
3. **Run the App**
   ```bash
   flutter run
   ```

## API Endpoints used in the app

### Fetch Media
**`GET /api/media`**  
Retrieves a list of media items.

### Like Media
**`POST /api/media/:id/like`**  
Likes a media item.

### Unlike Media
**`POST /api/media/:id/unlike`**  
Unlikes a media item.

### Get Pre-Signed URL
**`GET /api/media/preSignedURL`**  
Provides a secure URL for uploading media.

### Save Media
**`POST /api/media`**  
Saves the uploaded media to the database.

---

## Requirements and Libraries

### Flutter Packages
- **`http`**: For API requests.  
- **`image_picker`**: For selecting images from the device.  
- **`mime`**: For identifying the file MIME type.  

### API Requirements
- Ensure the backend service is running and accessible via the API base URL.
