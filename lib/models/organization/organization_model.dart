class Organization {
  final String id;
  final String name;
  final String? logoUrl;
  final String? description;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final DateTime? foundedDate;
  final int? employeeCount;
  final OrganizationSettings? settings;
  final List<Department>? departments;
  final List<Location>? locations;

  Organization({
    required this.id,
    required this.name,
    this.logoUrl,
    this.description,
    this.website,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.foundedDate,
    this.employeeCount,
    this.settings,
    this.departments,
    this.locations,
  });

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    return parts.join(', ');
  }

  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'T';
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Time Grid',
      logoUrl: json['logoUrl'] ?? json['logo_url'],
      description: json['description'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'] ?? json['zip_code'],
      country: json['country'],
      foundedDate: json['foundedDate'] != null || json['founded_date'] != null
          ? DateTime.tryParse(json['foundedDate'] ?? json['founded_date'])
          : null,
      employeeCount: json['employeeCount'] ?? json['employee_count'],
      settings: json['settings'] != null
          ? OrganizationSettings.fromJson(json['settings'])
          : null,
      departments: (json['departments'] as List<dynamic>?)
          ?.map((d) => Department.fromJson(d))
          .toList(),
      locations: (json['locations'] as List<dynamic>?)
          ?.map((l) => Location.fromJson(l))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'website': website,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'foundedDate': foundedDate?.toIso8601String(),
      'employeeCount': employeeCount,
      'settings': settings?.toJson(),
      'departments': departments?.map((d) => d.toJson()).toList(),
      'locations': locations?.map((l) => l.toJson()).toList(),
    };
  }
}

class OrganizationSettings {
  final String? timeZone;
  final String? dateFormat;
  final String? currency;
  final int? workDayStartHour;
  final int? workDayEndHour;
  final bool? enableBreaks;
  final int? defaultBreakDuration;

  OrganizationSettings({
    this.timeZone,
    this.dateFormat,
    this.currency,
    this.workDayStartHour,
    this.workDayEndHour,
    this.enableBreaks,
    this.defaultBreakDuration,
  });

  factory OrganizationSettings.fromJson(Map<String, dynamic> json) {
    return OrganizationSettings(
      timeZone: json['timeZone'] ?? json['time_zone'],
      dateFormat: json['dateFormat'] ?? json['date_format'],
      currency: json['currency'],
      workDayStartHour: json['workDayStartHour'] ?? json['work_day_start_hour'],
      workDayEndHour: json['workDayEndHour'] ?? json['work_day_end_hour'],
      enableBreaks: json['enableBreaks'] ?? json['enable_breaks'],
      defaultBreakDuration: json['defaultBreakDuration'] ?? json['default_break_duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeZone': timeZone,
      'dateFormat': dateFormat,
      'currency': currency,
      'workDayStartHour': workDayStartHour,
      'workDayEndHour': workDayEndHour,
      'enableBreaks': enableBreaks,
      'defaultBreakDuration': defaultBreakDuration,
    };
  }
}

class Department {
  final String id;
  final String name;
  final String? description;
  final int? employeeCount;
  final String? managerId;

  Department({
    required this.id,
    required this.name,
    this.description,
    this.employeeCount,
    this.managerId,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      employeeCount: json['employeeCount'] ?? json['employee_count'],
      managerId: json['managerId'] ?? json['manager_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'employeeCount': employeeCount,
      'managerId': managerId,
    };
  }
}

class Location {
  final String id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? phone;

  Location({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.phone,
  });

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    return parts.join(', ');
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'] ?? json['zip_code'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phone': phone,
    };
  }
}
