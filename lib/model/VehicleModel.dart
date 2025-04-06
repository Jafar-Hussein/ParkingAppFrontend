class VehicleModel {
  final int id;
  final String registreringsnummer;
  final String typ;
  final String owner;

  VehicleModel({
    required this.id,
    required this.registreringsnummer,
    required this.typ,
    required this.owner,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      registreringsnummer: json['registreringsnummer'],
      typ: json['typ'],
      owner: json['owner']['namn'],
    );
  }
}
