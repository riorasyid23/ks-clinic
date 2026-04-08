import express from 'express';
import type { Request, Response } from 'express';
import authRoutes from './routes/authRoutes.ts';
import { errorHandler, correlationIdMiddleware } from './middleware/errorHandler.ts';
import regionRoutes from './routes/regionRoutes.ts';
import userRoutes from './routes/userRoutes.ts';
import doctorRoutes from './routes/doctorRoutes.ts'
import encounterRoutes from './routes/encounterRoutes.ts'

const app = express();
const PORT = process.env.PORT || 8080;

// Middleware to parse JSON
app.use(express.json());

// Correlation ID middleware
app.use(correlationIdMiddleware);

// Routes
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/regions', regionRoutes);
app.use('/doctors', doctorRoutes)
app.use('/encounter', encounterRoutes)

// Hello World Endpoint
app.get('/', (req: Request, res: Response) => {
  res.status(200).json({
    message: "Welcome to the Clinic Booking API",
    status: "Healthy",
    timestamp: new Date().toISOString()
  });
});

// Error handling middleware (must be registered last)
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`🚀 Server is running at http://localhost:${PORT}`);
});