# 🏥 Medisify - Clinic Management Platform

Medisify is a modern, full-stack appointment booking and clinic management system. It provides a seamless experience for **Patients** to book medical services and for **Doctors/Clinical Staff** to manage schedules and patient encounters.

---

## 🏗️ Project Architecture

This repository is organized as a monorepo containing:
-   **`backend/`**: A robust, type-safe RESTful API built with **Node.js, Express, TypeScript, Prisma, and PostgreSQL**.
-   **`mobile/`**: A cross-platform mobile application developed with **Flutter & Riverpod**, following clean architecture principles.

---

## 🧪 Quick API Documentation & Testing

-   **API Reference**: You can view the live API documentation [here](https://ksclinic.docs.buildwithfern.com/).
-   **Debugging**: Backend logs are output to the terminal where `npm run dev` is executed.
-   **Database Visualizer**: You can use Prisma Studio to explore your data:
    ```bash
    cd backend && npx prisma studio
    ```

## FIGMA UI/UX Journey Details

You can view the UI/UX journey details in the Figma board [here](https://www.figma.com/board/Lf7aoxOM1RTG1QUNV08KGM/Clinic-Booking-Flow?node-id=0-1&p=f&t=PYf6MBQardYw2R7d-0).

---

## 🛠️ Backend Setup & Configuration

### Prerequisites
-   [Node.js](https://nodejs.org/) (v20+)
-   [PostgreSQL](https://www.postgresql.org/) database
-   [NPM](https://www.npmjs.com/) or [Yarn](https://yarnpkg.com/)

### Installation Steps

1.  Navigate into the backend directory:
    ```bash
    cd backend
    ```

2.  Install all dependencies:
    ```bash
    npm install
    ```

3.  **Environment Configuration**:
    Create a `.env` file in the `backend/` root:
    ```env
    DATABASE_URL="postgresql://user:password@localhost:5432/ks_clinic_db?schema=public"
    AUTH_SECRET="your_secure_jwt_secret"
    PORT=8080
    ```

4.  **Synchronize Database**:
    Run migrations to set up your local database schema:
    ```bash
    npx prisma migrate dev
    ```

5.  **Seed Initial Data (Optional)**:
    Populate the database with sample regions, doctors, and user accounts:
    ```bash
    # Ensure your database is running before this
    psql -U your_user -d ks_clinic_db -f prisma/seed.sql
    ```

6.  **Launch the API**:
    ```bash
    npm run dev
    ```
    The server will be reachable at `http://localhost:8080`.

---

## 📱 Mobile App Setup (Flutter)

### Prerequisites
-   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable)
-   [Dart SDK](https://dart.dev/get-dart)
-   An Android Emulator, iOS Simulator, or Physical Device.

### Installation Steps

1.  Navigate into the mobile directory:
    ```bash
    cd mobile
    ```

2.  Fetch Flutter packages:
    ```bash
    flutter pub get
    ```

3.  **Configure API Connection**:
    The mobile app connects to the local backend using the `DioClient`.
    -   **File**: `lib/core/network/dio_client.dart`
    -   **Local Machine**: `http://localhost:8080`
    -   **Android Emulator**: Change the URL to `http://10.0.2.2:8080` to bridge to your host machine's localhost.

4.  **Run the Application**:
    ```bash
    flutter run
    ```

---

## 🔑 Default Accounts (Post-Seeding)

If you use the provided `seed.sql`, you can log in with:

| Role | Email | Password |
|------|-------|----------|
| **Patient** | `riorasyid@ksclinic.com` | `12341234` |
| **Doctor** | `senku@ksclinic.com` | `12341234` |
| **Admin** | `admin1@ksclinic.com` | `12341234` |

---

## 📘 App Usage Guide

### 🚶 Patient Workflows

1.  **Register & Profile Setup**:
    -   Open the app and navigate to **Register**.
    -   Fill in your account details (Email, Password) in Step 1.
    -   Provide personal information (Full Name, Phone) in Step 2.
    -   After login, go to the **Profile** tab and click **Complete Medical Profile** to add DOB, blood type, and health stats.

2.  **Booking an Appointment**:
    -   From the **Home Screen**, use the search bar or category icons to find a doctor.
    -   Select a doctor to view their profile and available working hours.
    -   Choose a convenient date and an available time slot.
    -   Enter the reason for your visit and confirm your booking.

3.  **Managing Appointments**:
    -   View your upcoming and past visits in the **My Bookings** tab.
    -   Select any booking to see its status (Pending, Confirmed, Completed).
    -   **Cancellation**: You can cancel a *Pending* appointment directly from the booking details screen.

### 🩺 Doctor & Staff Workflows

1.  **Managing Availability**:
    -   Navigate to the **Availability** tab (exclusive to the Doctor role).
    -   Use the **+** (Plus) button to add new weekly working hours.
    -   Set your start time, end time, and session duration for each day.

2.  **Handling Appointments**:
    -   View your daily schedule and incoming requests from the **Dashboard** (Home).
    -   **Confirming**: Open a *Pending* booking and click **Confirm** to acknowledge the patient’s request.
    -   **Completion**: After the clinical session, open the *Confirmed* booking and mark it as **Complete**.

---

