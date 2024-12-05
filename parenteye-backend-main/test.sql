SELECT *
FROM Events
WHERE eventTimestamp >= strftime('%s', 'now')  -- Only recent events
AND eventTimestamp <= strftime('%s', 'now', '+1 month')
AND (6371 * acos(
				cos(radians(47.6091814)) * cos(radians(locationLat)) *
				cos(radians(locationLng) - radians(-122.1795901)) +
				sin(radians(47.6091814)) * sin(radians(locationLat))
		)) <= 10
ORDER BY eventTimestamp ASC
LIMIT 10;

