import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';

class CompanionController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();

  final List<String> quickPrompts = [
    'When should I take Amlodipine?',
    'Can I eat salty food?',
    'How long should I walk today?',
    'When is my next doctor follow-up?',
  ];

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

  Future<void> sendMessage([String? prompt]) async {
    final text = (prompt ?? textController.text).trim();
    if (text.isEmpty || isSending.value) return;

    if (prompt == null) {
      textController.clear();
    }

    // Add optimistic user message
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
      // Add error message as companion bubble
      messages.add(
        ChatMessage(
          id: 'err-${DateTime.now().millisecondsSinceEpoch}',
          role: 'companion',
          content: 'Sorry, I am having trouble connecting to the recovery service right now.',
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

