# KS Clinic API Backend

A robust, type-safe RESTful API for managing clinic operations, including patient registrations, doctor scheduling, and appointment bookings.

## Quick Docs:
You can directly visit the fern site i create for documenting API [here](https://ksclinic.docs.buildwithfern.com/)


## 🚀 Tech Stack

- **Runtime**: [Node.js](https://nodejs.org/) (v20+)
- **Framework**: [Express.js](https://expressjs.com/) (v5.x)
- **Language**: [TypeScript](https://www.typescriptlang.org/)
- **ORM**: [Prisma](https://www.prisma.io/)
- **Database**: [PostgreSQL](https://www.postgresql.org/)
- **Validation**: [Zod](https://zod.dev/)
- **Authentication**: [JWT](https://jwt.io/) (JSON Web Tokens)
- **Development**: [Nodemon](https://nodemon.io/), [ts-node](https://typestrong.org/ts-node/)

## 📂 Project Structure

```text
src/
├── controllers/    # Request handlers & business logic
├── generated/      # Auto-generated Prisma client
├── helpers/        # Utility functions (e.g., slot calculation, JWT)
├── lib/            # Shared instances (e.g., Prisma client)
├── middleware/     # Auth, RBAC, Error Handling, Validation
├── routes/         # API route definitions
├── schemas/        # Zod validation schemas
├── utils/          # Error classes and async wrappers
└── index.ts        # App entry point
```

## 🛠️ Getting Started

### Prerequisites

- Node.js installed
- PostgreSQL database
- Docker (optional, for database/containerization)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd ks-clinic/backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure Environment Variables:
   Create a `.env` file in the root directory:
   ```env
   DATABASE_URL="postgresql://user:password@localhost:5432/clinic_db"
   AUTH_SECRET="your_jwt_secret_key"
   PORT=8080
   ```

4. Run Database Migrations:
   ```bash
   npx prisma migrate dev
   ```

5. Start the development server:
   ```bash
   npm run dev
   ```

### 🧪 Database Seeding

To quickly populate your database with sample data for development and testing:

```bash
# Using psql command line
psql -U <db_user> -d <db_name> -f prisma/seed.sql
```
*(Make sure to replace `<db_user>` and `<db_name>` with your actual database credentials.)*

## 🔐 Authentication & Authorization

The API uses JWT-based authentication. Roles include:
- `PATIENT`: Can book appointments and manage their profile.
- `DOCTOR`: Can view schedules and manage patient encounters.
- `ADMIN`: Full access to clinic regions, doctor profiles, and system-wide data.

Include the token in your requests:
`Authorization: Bearer <your_token>`

## 📡 API Endpoints Summary

| Feature | Base Path | Description |
|---------|-----------|-------------|
| **Auth** | `/auth` | Registration, Login, and Token validation. |
| **Users** | `/users` | Patient profile management (DOB, health stats). |
| **Regions**| `/regions` | Clinic locations and branch details. |
| **Doctors**| `/doctors` | Doctor profiles, specialties, and weekly schedules. |
| **Encounters**| `/encounter` | Appointment booking, status updates, and history. |
| **Insights** | `/insights` | Statistics and dashboard data. |

## 🧪 Error Handling

The project implements a centralized error-handling strategy. All errors follow a consistent format:
```json
{
  "correlationId": "uuid-v4",
  "error": {
    "code": "BAD_REQUEST",
    "message": "Detailed error message",
    "details": { ... }
  }
}
```
See `ERROR_HANDLING_GUIDE.md` for more details on error codes and troubleshooting.

## 🐳 Docker

Run the entire stack (App + Postgres) using Docker Compose:
```bash
docker-compose up -d
```

## 📜 License

ISC License
