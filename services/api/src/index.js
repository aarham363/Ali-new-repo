import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { Client as PgClient } from 'pg';
import Redis from 'ioredis';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const port = process.env.PORT || 8080;
const databaseUrl = process.env.DATABASE_URL || 'postgres://univid:univid@localhost:5432/univid';
const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
const mockMode = String(process.env.MOCK_MODE || '').toLowerCase() === 'true';

const pgClient = mockMode ? null : new PgClient({ connectionString: databaseUrl });
const redisClient = mockMode ? null : new Redis(redisUrl);

app.get('/health', async (_req, res) => {
	try {
		if (mockMode) {
			return res.json({ status: 'ok', mode: 'mock' });
		}
		await pgClient.query('SELECT 1 as ok');
		await redisClient.ping();
		res.json({ status: 'ok', mode: 'live' });
	} catch (err) {
		res.status(500).json({ status: 'error', error: String(err?.message || err) });
	}
});

app.get('/version', (_req, res) => {
	res.json({ name: 'univid-pro-api', version: '0.1.0' });
});

async function start() {
	try {
		if (!mockMode) {
			await pgClient.connect();
			await redisClient.ping();
		}
		app.listen(port, () => {
			console.log(`API listening on :${port} (mockMode=${mockMode})`);
		});
	} catch (error) {
		console.error('Failed to start API:', error);
		process.exit(1);
	}
}

start();