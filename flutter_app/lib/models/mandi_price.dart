class MandiPrice {
  final String state;
  final String district;
  final String market;
  final String commodity;
  final String variety;
  final double minPrice;
  final double modalPrice;
  final double maxPrice;
  final DateTime reportedDate;

  MandiPrice({
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    required this.variety,
    required this.minPrice,
    required this.modalPrice,
    required this.maxPrice,
    required this.reportedDate,
  });

  factory MandiPrice.fromJson(Map<String, dynamic> json) {
    // API returns price strings like "2300"
    double parsePrice(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    // Reported date comes as "DD/MM/YYYY"
    DateTime parseDate(String dateStr) {
      try {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
      return DateTime.now();
    }

    return MandiPrice(
      state: (json['State'] ?? json['state'] ?? 'Unknown State') as String,
      district: (json['District'] ?? json['district'] ?? 'Unknown District') as String,
      market: (json['Market'] ?? json['market'] ?? 'Unknown Market') as String,
      commodity: (json['Commodity'] ?? json['commodity'] ?? 'Unknown Crop') as String,
      variety: (json['Variety'] ?? json['variety'] ?? 'Unknown Variety') as String,
      minPrice: parsePrice(json['Min_Price'] ?? json['min_price'] ?? json['Min_x0020_Price']),
      modalPrice: parsePrice(json['Modal_Price'] ?? json['modal_price'] ?? json['Modal_x0020_Price']),
      maxPrice: parsePrice(json['Max_Price'] ?? json['max_price'] ?? json['Max_x0020_Price']),
      reportedDate: parseDate((json['Arrival_Date'] ?? json['arrival_date'] ?? json['reported_date'] ?? '') as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'state': state,
        'district': district,
        'market': market,
        'commodity': commodity,
        'variety': variety,
        'min_price': minPrice,
        'modal_price': modalPrice,
        'max_price': maxPrice,
        'reported_date': reportedDate.toIso8601String(),
      };
}
