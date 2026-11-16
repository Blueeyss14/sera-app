class AuthUser {
  final String id;
  final String role;
  final String email;
  final String name;
  final String? phone;
  final bool isVerified;
  final String? patientId;
  final String? doctorId;

  AuthUser({
    required this.id,
    required this.role,
    required this.email,
    required this.name,
    this.phone,
    required this.isVerified,
    this.patientId,
    this.doctorId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'patient',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      isVerified: json['isVerified'] == true,
      patientId: json['patientId']?.toString(),
      doctorId: json['doctorId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'email': email,
      'name': name,
      'phone': phone,
      'isVerified': isVerified,
      'patientId': patientId,
      'doctorId': doctorId,
    };
  }
}

class AuthResponse {
  final AuthUser user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token']?.toString() ?? '',
    );
  }
}

class Patient {
  final String id;
  final String mrn;
  final String name;
  final String gender;
  final String birthDate;
  final String phone;
  final String? guardianName;
  final String? guardianPhone;
  final String? address;
  final String? primaryDiagnosis;
  final List<String> conditions;
  final List<String> allergies;
  final String? assignedDoctorId;

  Patient({
    required this.id,
    required this.mrn,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.phone,
    this.guardianName,
    this.guardianPhone,
    this.address,
    this.primaryDiagnosis,
    this.conditions = const [],
    this.allergies = const [],
    this.assignedDoctorId,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id']?.toString() ?? '',
      mrn: json['mrn']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'male',
      birthDate: json['birthDate']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      guardianName: json['guardianName']?.toString(),
      guardianPhone: json['guardianPhone']?.toString(),
      address: json['address']?.toString(),
      primaryDiagnosis: json['primaryDiagnosis']?.toString(),
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      assignedDoctorId: json['assignedDoctorId']?.toString(),
    );
  }
}

class HealthHistoryEntry {
  final String id;
  final String patientId;
  final String date;
  final String type;
  final String title;
  final String notes;
  final String? value;

  HealthHistoryEntry({
    required this.id,
    required this.patientId,
    required this.date,
    required this.type,
    required this.title,
    required this.notes,
    this.value,
  });

  factory HealthHistoryEntry.fromJson(Map<String, dynamic> json) {
    return HealthHistoryEntry(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      value: json['value']?.toString(),
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String email;
  final String hospital;
  final String? bio;
  final String? avatarUrl;
  final String? phone;
  final String consultationStatus;
  final String? activeRequestId;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.email,
    required this.hospital,
    this.bio,
    this.avatarUrl,
    this.phone,
    this.consultationStatus = 'none',
    this.activeRequestId,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      hospital: json['hospital']?.toString() ?? '',
      bio: json['bio']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      phone: json['phone']?.toString(),
      consultationStatus: json['consultationStatus']?.toString() ?? 'none',
      activeRequestId: json['activeRequestId']?.toString(),
    );
  }
}

class CarePlanItem {
  final String id;
  final String kind;
  final String? drug;
  final String? dose;
  final List<String> times;
  final String? instruction;
  final int? durationDays;
  final String? category;
  final String? rule;
  final String? activity;
  final int? durationMinutes;
  final int? frequencyPerWeek;
  final String? subject;
  final String? date;

  CarePlanItem({
    required this.id,
    required this.kind,
    this.drug,
    this.dose,
    this.times = const [],
    this.instruction,
    this.durationDays,
    this.category,
    this.rule,
    this.activity,
    this.durationMinutes,
    this.frequencyPerWeek,
    this.subject,
    this.date,
  });

  factory CarePlanItem.fromJson(Map<String, dynamic> json) {
    return CarePlanItem(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      drug: json['drug']?.toString(),
      dose: json['dose']?.toString(),
      times: (json['times'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instruction: json['instruction']?.toString(),
      durationDays: json['durationDays'] as int?,
      category: json['category']?.toString(),
      rule: json['rule']?.toString(),
      activity: json['activity']?.toString(),
      durationMinutes: json['durationMinutes'] as int?,
      frequencyPerWeek: json['frequencyPerWeek'] as int?,
      subject: json['subject']?.toString(),
      date: json['date']?.toString(),
    );
  }

  String get title {
    if (kind == 'medication') return '${drug ?? ''} ${dose ?? ''}'.trim();
    if (kind == 'activity') return activity ?? 'Activity';
    if (kind == 'diet') return 'Diet: ${category ?? ''}'.trim();
    if (kind == 'restriction') return 'Avoid: ${subject ?? ''}'.trim();
    if (kind == 'followUp') return 'Doctor Follow-up';
    return kind;
  }

  String get subtitle {
    if (kind == 'medication') {
      final t = times.isNotEmpty ? times.join(', ') : 'Daily';
      return '$t · ${instruction ?? ''}';
    }
    if (kind == 'activity') {
      final f = frequencyPerWeek != null ? '$frequencyPerWeek x / week' : '';
      final d = durationMinutes != null ? '$durationMinutes mins' : '';
      return [f, d, instruction].where((s) => s != null && s.isNotEmpty).join(' · ');
    }
    return instruction ?? '';
  }
}

class CarePlan {
  final String id;
  final String patientId;
  final int version;
  final String status;
  final String sourceText;
  final String createdBy;
  final List<CarePlanItem> items;
  final String? confirmedAt;
  final Doctor? doctor;

  CarePlan({
    required this.id,
    required this.patientId,
    required this.version,
    required this.status,
    required this.sourceText,
    required this.createdBy,
    required this.items,
    this.confirmedAt,
    this.doctor,
  });

  factory CarePlan.fromJson(Map<String, dynamic> json) {
    return CarePlan(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      version: json['version'] as int? ?? 1,
      status: json['status']?.toString() ?? 'active',
      sourceText: json['sourceText']?.toString() ?? '',
      createdBy: json['createdBy']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CarePlanItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      confirmedAt: json['confirmedAt']?.toString(),
      doctor: json['doctor'] != null
          ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReminderView {
  final String key;
  final String itemId;
  final String kind;
  final String date;
  final String? time;
  final String title;
  final String detail;
  final String status;
  final String? completedAt;

  ReminderView({
    required this.key,
    required this.itemId,
    required this.kind,
    required this.date,
    this.time,
    required this.title,
    required this.detail,
    required this.status,
    this.completedAt,
  });

  bool get isDone => status == 'done';

  factory ReminderView.fromJson(Map<String, dynamic> json) {
    return ReminderView(
      key: json['key']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'medication',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString(),
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      status: json['status']?.toString() ?? 'upcoming',
      completedAt: json['completedAt']?.toString(),
    );
  }

  ReminderView copyWith({String? status, String? completedAt}) {
    return ReminderView(
      key: key,
      itemId: itemId,
      kind: kind,
      date: date,
      time: time,
      title: title,
      detail: detail,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class TodayScheduleResponse {
  final String date;
  final List<ReminderView> reminders;
  final int doneCount;
  final int totalCount;
  final ReminderView? nextReminder;
  final int? activePlanVersion;

  TodayScheduleResponse({
    required this.date,
    required this.reminders,
    required this.doneCount,
    required this.totalCount,
    this.nextReminder,
    this.activePlanVersion,
  });

  factory TodayScheduleResponse.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'] as Map<String, dynamic>?;
    final planSummary = json['activePlanSummary'] as Map<String, dynamic>?;

    return TodayScheduleResponse(
      date: json['date']?.toString() ?? '',
      reminders: (json['reminders'] as List<dynamic>?)
              ?.map((e) => ReminderView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      doneCount: progress?['done'] as int? ?? 0,
      totalCount: progress?['total'] as int? ?? 0,
      nextReminder: json['nextReminder'] != null
          ? ReminderView.fromJson(json['nextReminder'] as Map<String, dynamic>)
          : null,
      activePlanVersion: planSummary?['version'] as int?,
    );
  }
}

class AdherenceMetricsResponse {
  final String patientId;
  final int adherencePercentage;
  final int streak;

  AdherenceMetricsResponse({
    required this.patientId,
    required this.adherencePercentage,
    required this.streak,
  });

  factory AdherenceMetricsResponse.fromJson(Map<String, dynamic> json) {
    return AdherenceMetricsResponse(
      patientId: json['patientId']?.toString() ?? '',
      adherencePercentage: json['adherencePercentage'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
    );
  }
}

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final String scope;
  final Map<String, dynamic>? source;
  final bool isReported;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.scope,
    this.source,
    this.isReported = false,
    required this.createdAt,
  });

  bool get isPatient => role == 'patient';
  bool get isUrgent => scope == 'urgent';
  bool get isOutOfScope => scope == 'out-of-scope';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'companion',
      content: json['content']?.toString() ?? '',
      scope: json['scope']?.toString() ?? 'in-scope',
      source: json['source'] as Map<String, dynamic>?,
      isReported: json['isReported'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class WearableStatus {
  final bool isConnected;
  final String? deviceName;
  final String? lastSyncAt;

  WearableStatus({
    required this.isConnected,
    this.deviceName,
    this.lastSyncAt,
  });

  factory WearableStatus.fromJson(Map<String, dynamic> json) {
    final conn = json['connection'] as Map<String, dynamic>?;
    return WearableStatus(
      isConnected: json['isConnected'] == true,
      deviceName: conn?['deviceName']?.toString(),
      lastSyncAt: conn?['lastSyncAt']?.toString(),
    );
  }
}

