import jwt from 'jsonwebtoken';

type JwtPayload = {
    userId: string;
    email: string;
    role: string;
}

export function generateAccessToken(payload: JwtPayload): string {
    // Implementation for generating access token
    return jwt.sign(payload, process.env.AUTH_SECRET as string, { expiresIn: '1h' });
}