/* Proboy API Client */
const API_BASE = '/cgi-bin/proboy-api';

const API = {
    async get(endpoint) {
        const resp = await fetch(`${API_BASE}${endpoint}`);
        return resp.json();
    },
    async post(endpoint, data) {
        const resp = await fetch(`${API_BASE}${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        return resp.json();
    },
    async start() { return this.post('/start'); },
    async stop() { return this.post('/stop'); },
    async restart() { return this.post('/restart'); },
    async status() { return this.get('/status'); },
    async system() { return this.get('/system'); }
};
