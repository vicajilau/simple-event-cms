class Organization {
  final String organizationName;
  final String primaryColorOrganization;
  final String secondaryColorOrganization;
  final String baseUrlOrganization;

  Organization({
    required this.organizationName,
    required this.primaryColorOrganization,
    required this.secondaryColorOrganization,
    required this.baseUrlOrganization,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        organizationName: json["organizationName"],
        primaryColorOrganization: json["primaryColorOrganization"],
        secondaryColorOrganization: json["secondaryColorOrganization"],
        baseUrlOrganization: json["baseUrlOrganization"],
      );
}