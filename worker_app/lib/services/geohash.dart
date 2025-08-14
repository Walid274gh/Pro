class GeoHashUtil {
	static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

	static String encode(double latitude, double longitude, {int precision = 9}) {
		final List<String> hash = <String>[];
		List<int> bits = [16, 8, 4, 2, 1];
		bool even = true;
		double latMin = -90.0, latMax = 90.0;
		double lonMin = -180.0, lonMax = 180.0;
		int bit = 0;
		int ch = 0;
		while (hash.length < precision) {
			if (even) {
				final double mid = (lonMin + lonMax) / 2;
				if (longitude > mid) {
					ch |= bits[bit];
					lonMin = mid;
				} else {
					lonMax = mid;
				}
			} else {
				final double mid = (latMin + latMax) / 2;
				if (latitude > mid) {
					ch |= bits[bit];
					latMin = mid;
				} else {
					latMax = mid;
				}
			}
			even = !even;
			if (bit < 4) {
				bit++;
			} else {
				hash.add(_base32[ch]);
				bit = 0;
				ch = 0;
			}
		}
		return hash.join();
	}
}