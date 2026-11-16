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

class AdherenceDay {
  final String date;
  final int done;
  final int total;

  AdherenceDay({required this.date, required this.done, required this.total});

  factory AdherenceDay.fromJson(Map<String, dynamic> json) {
    return AdherenceDay(
      date: json['date'] as String? ?? '',
      done: json['done'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class AdherenceTrendPoint {
  final String date;
  final int? medication;
  final int? activity;

  AdherenceTrendPoint({required this.date, this.medication, this.activity});

  factory AdherenceTrendPoint.fromJson(Map<String, dynamic> json) {
    return AdherenceTrendPoint(
      date: json['date'] as String? ?? '',
      medication: json['medication'] as int?,
      activity: json['activity'] as int?,
    );
  }
}

class AdherenceTrendSummary {
  final int? medicationAverage;
  final int? activityAverage;
  final Map<String, dynamic>? lowest;

  AdherenceTrendSummary({this.medicationAverage, this.activityAverage, this.lowest});

  factory AdherenceTrendSummary.fromJson(Map<String, dynamic> json) {
    return AdherenceTrendSummary(
      medicationAverage: json['medicationAverage'] as int?,
      activityAverage: json['activityAverage'] as int?,
      lowest: json['lowest'] as Map<String, dynamic>?,
    );
  }
}

class AdherenceMetricsResponse {
  final String patientId;
  final int adherencePercentage;
  final int streak;
  final List<AdherenceDay> days;
  final List<AdherenceTrendPoint> trend;
  final AdherenceTrendSummary? summary;

  AdherenceMetricsResponse({
    required this.patientId,
    required this.adherencePercentage,
    required this.streak,
    this.days = const [],
    this.trend = const [],
    this.summary,
  });

  factory AdherenceMetricsResponse.fromJson(Map<String, dynamic> json) {
    final daysList = json['days'] as List<dynamic>? ?? [];
    final trendList = json['trend'] as List<dynamic>? ?? [];

    return AdherenceMetricsResponse(
      patientId: json['patientId']?.toString() ?? '',
      adherencePercentage: json['adherencePercentage'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      days: daysList.map((e) => AdherenceDay.fromJson(e as Map<String, dynamic>)).toList(),
      trend: trendList.map((e) => AdherenceTrendPoint.fromJson(e as Map<String, dynamic>)).toList(),
      summary: json['summary'] != null
          ? AdherenceTrendSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DailyWearableData {
  final int steps;
  final int heartRateResting;
  final int heartRateMin;
  final int heartRateMax;
  final int sleepMinutes;
  final int spo2;

  DailyWearableData({
    required this.steps,
    required this.heartRateResting,
    required this.heartRateMin,
    required this.heartRateMax,
    required this.sleepMinutes,
    required this.spo2,
  });

  factory DailyWearableData.fromJson(Map<String, dynamic> json) {
    final stepsMap = json['steps'] as Map<String, dynamic>?;
    final hrMap = json['heartRate'] as Map<String, dynamic>?;
    final sleepMap = json['sleep'] as Map<String, dynamic>?;
    final spo2Map = json['spo2'] as Map<String, dynamic>?;

    return DailyWearableData(
      steps: stepsMap?['total'] as int? ?? 0,
      heartRateResting: hrMap?['resting'] as int? ?? 72,
      heartRateMin: hrMap?['min'] as int? ?? 60,
      heartRateMax: hrMap?['max'] as int? ?? 115,
      sleepMinutes: sleepMap?['totalMinutes'] as int? ?? 420,
      spo2: spo2Map?['average'] as int? ?? 97,
    );
  }
}

class FeedbackEntry {
  final String id;
  final String patientId;
  final String userId;
  final String? doctorId;
  final String category;
  final String message;
  final String status;
  final String? resolvedAt;
  final String? resolvedBy;
  final String createdAt;
  final String? patientName;
  final String? doctorName;

  FeedbackEntry({
    required this.id,
    required this.patientId,
    required this.userId,
    this.doctorId,
    required this.category,
    required this.message,
    required this.status,
    this.resolvedAt,
    this.resolvedBy,
    required this.createdAt,
    this.patientName,
    this.doctorName,
  });

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? json['patient_id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? json['doctor_id'] as String?,
      category: json['category'] as String? ?? 'other',
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      resolvedAt: json['resolvedAt'] as String? ?? json['resolved_at'] as String?,
      resolvedBy: json['resolvedBy'] as String? ?? json['resolved_by'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      patientName: json['patientName'] as String? ?? json['patient_name'] as String?,
      doctorName: json['doctorName'] as String? ?? json['doctor_name'] as String?,
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
  final String? connectedAt;

  WearableStatus({
    required this.isConnected,
    this.deviceName,
    this.lastSyncAt,
    this.connectedAt,
  });

  factory WearableStatus.fromJson(Map<String, dynamic> json) {
    final conn = json['connection'] as Map<String, dynamic>?;
    return WearableStatus(
      isConnected: json['isConnected'] == true,
      deviceName: conn?['deviceName']?.toString(),
      lastSyncAt: conn?['lastSyncAt']?.toString(),
      connectedAt: conn?['connectedAt']?.toString(),
    );
  }
}

class MetricStat {
  final String key;
  final String label;
  final String value;
  final String unit;

  MetricStat({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  factory MetricStat.fromJson(Map<String, dynamic> json) {
    return MetricStat(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
    );
  }
}

class TrendPoint {
  final String key;
  final String label;
  final num? value;
  final num? low;
  final num? high;

  TrendPoint({
    required this.key,
    required this.label,
    this.value,
    this.low,
    this.high,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      value: json['value'] as num?,
      low: json['low'] as num?,
      high: json['high'] as num?,
    );
  }
}

class MetricTrend {
  final List<TrendPoint> points;
  final MetricStat headline;
  final List<MetricStat> stats;

  MetricTrend({
    required this.points,
    required this.headline,
    required this.stats,
  });

  factory MetricTrend.fromJson(Map<String, dynamic> json) {
    final pointsList = json['points'] as List<dynamic>? ?? [];
    final statsList = json['stats'] as List<dynamic>? ?? [];
    final headlineMap = json['headline'] as Map<String, dynamic>? ?? {};

    return MetricTrend(
      points: pointsList.map((e) => TrendPoint.fromJson(e as Map<String, dynamic>)).toList(),
      headline: MetricStat.fromJson(headlineMap),
      stats: statsList.map((e) => MetricStat.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class WearableDayTrends {
  final MetricTrend? steps;
  final MetricTrend? heartRate;
  final MetricTrend? sleep;
  final MetricTrend? spo2;

  WearableDayTrends({
    this.steps,
    this.heartRate,
    this.sleep,
    this.spo2,
  });

  factory WearableDayTrends.fromJson(Map<String, dynamic> json) {
    final stepsMap = json['steps'] as Map<String, dynamic>?;
    final hrMap = (json['heart-rate'] ?? json['heartRate']) as Map<String, dynamic>?;
    final sleepMap = json['sleep'] as Map<String, dynamic>?;
    final spo2Map = json['spo2'] as Map<String, dynamic>?;

    return WearableDayTrends(
      steps: stepsMap != null ? MetricTrend.fromJson(stepsMap) : null,
      heartRate: hrMap != null ? MetricTrend.fromJson(hrMap) : null,
      sleep: sleepMap != null ? MetricTrend.fromJson(sleepMap) : null,
      spo2: spo2Map != null ? MetricTrend.fromJson(spo2Map) : null,
    );
  }
}

