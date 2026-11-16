import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';
import '../../../../core/services/session_service.dart';
import '../../../../res/assets.dart';

class CompanionController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxSet<String> reportedMessageIds = <String>{}.obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();

  String get firstName {
    final name = SessionService.to.user.value?.name;
    if (name == null || name.isEmpty) return 'Patient';
    return name.trim().split(' ').first;
  }

  String get mascotPoseAsset {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return ImageAssets.seraGreeting;
    } else if (hour >= 18) {
      return ImageAssets.seraSleepy;
    } else {
      return ImageAssets.seraHappy;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final list = await ApiService.instance.getCompanionHistory();
      messages.value = list;
      _scrollToBottom();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void reportMessage(String messageId) {
    reportedMessageIds.add(messageId);
    Get.snackbar(
      'Reported',
      'Thank you. This response has been reported for review.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  bool isMessageReported(ChatMessage msg) {
    return msg.isReported || reportedMessageIds.contains(msg.id);
  }

  Future<void> sendMessage([String? prompt]) async {
    final text = (prompt ?? textController.text).trim();
    if (text.isEmpty || isSending.value) return;

    if (prompt == null) {
      textController.clear();
    }

    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final userMsg = ChatMessage(
      id: tempId,
      role: 'patient',
      content: text,
      scope: 'in-scope',
      createdAt: DateTime.now().toIso8601String(),
    );
    messages.add(userMsg);
    _scrollToBottom();

    isSending.value = true;
    try {
      final reply = await ApiService.instance.sendCompanionMessage(text);
      messages.add(reply);
      _scrollToBottom();
    } catch (e) {
      messages.add(
        ChatMessage(
          id: 'err-${DateTime.now().millisecondsSinceEpoch}',
          role: 'companion',
          content:
              'Sorry, I am having trouble connecting to the recovery service right now.',
          scope: 'in-scope',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      _scrollToBottom();
    } finally {
      isSending.value = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
