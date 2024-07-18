# Shop Listings App

This Flutter application is a simple shop listings management system that allows users to create, read, update, and delete product listings. It uses Firebase for authentication and data storage.

## Features

1. **User Authentication**
   - Users can create a new account with email and password
   - Existing users can log in to their account
   - Email verification is required for new accounts
   - Users can log out of their account

2. **Product Management**
   - Users can add new products with name and price
   - View a list of all added products
   - Edit existing product details
   - Delete products from the list

3. **User Interface**
   - Clean and intuitive interface with a dark theme
   - Responsive design that adapts to different screen sizes
   - Drawer menu for easy navigation and logout
   - Floating action button for quick addition of new products

4. **Data Persistence**
   - All product data is stored in Firebase Firestore
   - Each user has their own collection of products
   - Real-time updates when products are added, modified, or deleted

5. **Form Validation**
   - Input validation for email, password, product name, and price
   - Ensure all required fields are filled before submission

6. **Error Handling**
   - Proper error messages for authentication issues
   - Feedback to users for successful operations (login, registration, CRUD operations)

7. **Security**
   - Secure authentication using Firebase Auth
   - Each user can only access and modify their own data

This app provides a straightforward way for shop owners or managers to keep track of their product listings, with the convenience of cloud storage and real-time updates across devices.


---
## Reference
For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
