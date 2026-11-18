import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';
import '../../../../core/services/session_service.dart';

class TodayController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rxn<TodayScheduleResponse> schedule = Rxn<TodayScheduleResponse>();
  final Rxn<AdherenceMetricsResponse> adherence =
      Rxn<AdherenceMetricsResponse>();
  final Rxn<CarePlan> activePlan = Rxn<CarePlan>();
  final Rxn<WearableStatus> wearable = Rxn<WearableStatus>();
  final Rxn<Patient> patient = Rxn<Patient>();

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Good morning';
    if (hour < 15) return 'Good afternoon';
    if (hour < 18) return 'Good evening';
    return 'Good evening';
  }

  String get patientFirstName {
    final user = SessionService.to.user.value;
    if (user != null && user.name.isNotEmpty) {
      return user.name.split(' ').first;
    }
    return 'User';
  }

  String get honorific {
    final gender = patient.value?.gender;
    if (gender == '') return '';
    return '';
  }

  String get currentDateFormatted {
    return DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()).toUpperCase();
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final patientId = SessionService.to.user.value?.patientId ?? 'p-001';

      final results = await Future.wait([
        ApiService.instance.getTodaySchedule(dateStr),
        ApiService.instance.getPatientAdherence(),
        ApiService.instance.getPatientActivePlan(),
        ApiService.instance.getWearableStatus(),
        ApiService.instance.getPatientDetail(patientId),
      ]);

      schedule.value = results[0] as TodayScheduleResponse?;
      adherence.value = results[1] as AdherenceMetricsResponse?;
      activePlan.value = results[2] as CarePlan?;
      wearable.value = results[3] as WearableStatus?;
      patient.value = results[4] as Patient?;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleReminder(ReminderView reminder) async {
    final currentSchedule = schedule.value;
    if (currentSchedule == null) return;

    final isCurrentlyDone = reminder.isDone;
    final newStatus = isCurrentlyDone ? 'upcoming' : 'done';

    final updatedList = currentSchedule.reminders.map((r) {
      if (r.key == reminder.key) {
        return r.copyWith(status: newStatus);
      }
      return r;
    }).toList();

    final newDoneCount = isCurrentlyDone
        ? (currentSchedule.doneCount - 1).clamp(0, currentSchedule.totalCount)
        : (currentSchedule.doneCount + 1).clamp(0, currentSchedule.totalCount);

    ReminderView? newNextReminder;
    final remaining = updatedList.where((r) => r.status != 'done').toList();
    if (remaining.isNotEmpty) {
      final overdue = remaining.firstWhereOrNull((r) => r.status == 'overdue');
      newNextReminder = overdue ?? remaining.first;
    }

    schedule.value = TodayScheduleResponse(
      date: currentSchedule.date,
      reminders: updatedList,
      doneCount: newDoneCount,
      totalCount: currentSchedule.totalCount,
      nextReminder: newNextReminder,
      activePlanVersion: currentSchedule.activePlanVersion,
    );

    try {
      await ApiService.instance.toggleReminder(
        key: reminder.key,
        itemId: reminder.itemId,
        kind: reminder.kind,
        date: reminder.date,
        time: reminder.time,
      );
    } catch (_) {
      schedule.value = currentSchedule;
    }
  }
}
