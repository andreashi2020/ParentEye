export interface Env {
	DB: D1Database;
	GOOGLE_MAP_API_KEY: string;
	ENV: string;
}

export default {
	async fetch(request: Request, env: Env) {
		try {
			console.log('[Debug] Worker started');
			console.log('[Debug] Request URL:', request.url);

			// Parse request URL and parameters
			const url = new URL(request.url);
			console.log('[Debug] Pathname:', url.pathname);

			if (url.pathname === '/') {
				console.log('[Debug] Handling root path');
				const hello = JSON.stringify({ msg: 'hello' });
				return new Response(hello, {
					headers: {
						'Content-Type': 'application/json',
						'Access-Control-Allow-Origin': '*', // Add CORS headers
					},
				});
			} else if (url.pathname === '/getNearbyLatestEvents') {
				console.log('[Debug] Handling getNearbyLatestEvents');
				return this.getNearbyLatestEvents(request, env);
			} else {
				console.log('[Debug] Path not found:', url.pathname);
				const notFound = JSON.stringify({ msg: 'not found' });
				return new Response(notFound, {
					headers: {
						'Content-Type': 'application/json',
						'Access-Control-Allow-Origin': '*', // Add CORS headers
					},
					status: 404,
				});
			}
		} catch (error) {
			console.error('[Debug] Global error:', error);
			return new Response(JSON.stringify({ error: 'Internal Server Error', details: error }), {
				status: 500,
				headers: {
					'Content-Type': 'application/json',
					'Access-Control-Allow-Origin': '*',
				},
			});
		}
	},

	async getNearbyLatestEvents(request: Request, env: Env): Promise<Response> {
		try {
			console.log('[Debug] Starting getNearbyLatestEvents');
			const url = new URL(request.url);

			const latitude = parseFloat(url.searchParams.get('latitude') ?? '47.6091813999999971');
			const longitude = parseFloat(url.searchParams.get('longitude') ?? '-122.1795900999999987');
			const rangeInKm = parseFloat(url.searchParams.get('rangeInKm') ?? '10');
			const numOfResult = parseInt(url.searchParams.get('numOfResult') ?? '10');

			console.log('[Debug] Parameters:', { latitude, longitude, rangeInKm, numOfResult });

			if (isNaN(latitude) || isNaN(longitude)) {
				console.log('[Debug] Invalid coordinates');
				return new Response(JSON.stringify({ error: 'Invalid latitude or longitude' }), {
					status: 400,
					headers: {
						'Content-Type': 'application/json',
						'Access-Control-Allow-Origin': '*',
					},
				});
			}

			const query = `
				SELECT *
				FROM Events
				WHERE eventTimestamp >= strftime('%s', 'now')
				AND eventTimestamp <= strftime('%s', 'now', '+1 month')
				AND (6371 * acos(
								cos(radians(?)) * cos(radians(locationLat)) *
								cos(radians(locationLng) - radians(?)) +
								sin(radians(?)) * sin(radians(locationLat))
						)) <= ?
				ORDER BY eventTimestamp ASC
				LIMIT ?;
			`;

			console.log('[Debug] Executing DB query');
			const { results } = await env.DB.prepare(query).bind(latitude, longitude, latitude, rangeInKm, numOfResult).all();

			console.log('[Debug] Query results:', results);

			return new Response(JSON.stringify(results), {
				headers: {
					'Content-Type': 'application/json',
					'Access-Control-Allow-Origin': '*',
				},
			});
		} catch (error) {
			console.error('[Debug] Database error:', error);
			return new Response(JSON.stringify({ error: 'Failed to fetch events', details: error }), {
				status: 500,
				headers: {
					'Content-Type': 'application/json',
					'Access-Control-Allow-Origin': '*',
				},
			});
		}
	},
};
