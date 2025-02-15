class Location {
  final double lat;
  final double lng;
  final String name;
  final String? streetAddress;
  final String? city;
  final String? province;
  final String? postalCode;

  const Location(this.lat, this.lng, this.name, this.streetAddress, this.city,
      this.province, this.postalCode);
}
