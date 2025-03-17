# Banquet Management App

This Banquet Management App was developed for the students of Sindh Madarsatul Islam University Karachi. It utilizes **Firebase** for database management, **GetX** for state management, **Flutter Maps** for location services, live chat functionality, and more to streamline banquet management processes.

## Features

### Venue Booker
The **Venue Booker** is a user who can book banquets and manage their bookings. The following are the features available to Venue Bookers:

1. **Register and Login**: Users can register, log in, and manage their profile.
2. **View Banquet List**: Users can see a list of available banquets with detailed information.
3. **Book Banquet**: Users can make multiple bookings for banquets.
4. **Booking Approval**: Bookings will be sent for owner approval, and users cannot cancel confirmed bookings.
5. **Cancel Booking**: If the owner has not confirmed the booking, the user can cancel it.
6. **Rate Completed Bookings**: After a booking is completed, the user can rate their experience.
7. **View All Bookings**: Users can see a list of their past and current bookings.
8. **Local Notifications**: Users receive local notifications about their bookings, status changes, and other important events.
9. **Profile Management**: Users can view and edit their profile, with skeleton loader for smooth loading.
10. **Snackbar Messages**: Snackbar messages appear on actions across the app for feedback.
11. **Live Data**: Users see live updates for banquet availability and booking status (e.g., new bookings or booking status changes).

### Venue Owner
The **Venue Owner** has control over the venue and booking management. The following are the features available to Venue Owners:

1. **Register, Login, and Profile**: Owners can register, log in, and manage their profiles.
2. **Dashboard**: Owners have a dashboard where they can view all activities and manage their venue.
3. **Add, Edit, or Delete Banquets**: Owners can add new banquets, edit existing banquet details, or delete banquets.
4. **Booking Management**: Owners can accept or reject bookings made by Venue Bookers.
5. **Notification System**: Owners are notified when a new booking is received and when a booking status changes.
6. **View Bookings**: Owners can view all bookings with their statuses, such as **Pending**, **Confirmed**, **Rejected**, **Completed**, and **Cancelled**.
7. **Chat Functionality**: Owners and Bookers can chat in real-time, making communication seamless and efficient.

## Booking Statuses

1. **Pending**: When a user makes a booking, but the owner hasn't accepted or rejected it yet.
2. **Confirmed**: When the owner confirms the booking.
3. **Rejected**: When the owner rejects the booking.
4. **Completed**: When the booking has passed, and the rating flow starts.
5. **Cancelled**: When the Venue Booker cancels the booking (this deletes the entry from the database).

## Notification System
1. Venue Bookers receive notifications whenever their booking status changes.
2. A small round indicator on the notification icon shows updates about new bookings or status changes.

## Flutter Version
The Flutter version used for this project is mentioned in the `pubspec.yaml` file. Please refer to it for compatibility and setup.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/banquet-management-app.git
   ```
2. Navigate into the project directory:

  ```bash
  cd banquet-management-app
  ```
3. Install dependencies:

  ```bash
  flutter pub get
```
4. Run the app:

  ```bash
flutter run
```
### Usage:
Feel free to use the code for your own projects or as a reference. If you run into any issues or have any questions, feel free to contact me, and I'll be happy to assist you.

### License:
This project is open-source, and you're welcome to use or modify the code. However, please make sure to give credit where it's due.

### Contact:
If you need help or have any questions, don't hesitate to reach out to me. I'm happy to assist you with any problems you may face.

### Key Sections Included:
App Overview: General introduction and technologies used.
Role-based Features: Clear separation of features for Venue Booker and Venue Owner.
Booking Statuses: Explanation of various booking statuses (Pending, Confirmed, Rejected, Completed, and Cancelled).
Notification System: Explanation of the notification flow.
Flutter Version: Notes about the Flutter version in pubspec.yaml.
Installation & Usage: Steps to install and run the app.
License & Contact: Encouragement to use the code, along with contact details for support.
Feel free to modify any of the content further based on your project details or any specific updates you'd like to make. Let me know if you need more assistance!

### What’s Included:
- **App Overview**: Describes the app’s purpose and technologies.
- **Role-based Features**: Separate sections for **Venue Booker** and **Venue Owner** features.
- **Booking Statuses**: Explanation of how bookings are handled.
- **Notification System**: Details about notification flow for status changes.
- **Flutter Version**: Information about the Flutter version (referenced in `pubspec.yaml`).
- **Installation & Usage**: Detailed steps to clone the repo, install dependencies, and run the app.
- **License & Contact**: Encouraging others to use and modify the code while providing a way to reach out for support.

This version should now fully cover the features and setup for your project. Let me know if anything else needs to be adjusted!



