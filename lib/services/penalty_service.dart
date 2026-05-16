import 'dart:math';

class PenaltyService {
  static final PenaltyService _instance = PenaltyService._internal();
  factory PenaltyService() => _instance;
  PenaltyService._internal();

  int _freezePoints = 0;
  final Random _random = Random();

  // يحسب ما إذا كان المستخدم سيُعاقب بناءً على أدائه اليومي
  bool shouldApplyPenalty(int currentSteps, int targetSteps, int currentWater, int targetWater) {
    if (currentSteps < targetSteps * 0.7 || currentWater < targetWater * 0.7) {
      return true;
    }
    return false;
  }

  // يطبق عقوبة "تجميد النقاط" ويرجع عدد النقاط المجمدة
  int applyFreeze(int failedDaysCount) {
    _freezePoints = (failedDaysCount * 0.5).ceil();
    return _freezePoints;
  }

  // يعيد رسالة تحفيزية "قاسية" حسب مستوى الفشل
  String getMotivationalMessage(int failedDaysCount) {
    final messages = [
      'لقد فشلت بالأمس. هل هذه هي قوتك؟',
      'لا تكن ضعيفاً. التحدي يحتاج أبطالاً.',
      'خصم نقاطك بسبب تقاعسك. استيقظ!',
      'العظماء لا يتوقفون. عد للمسار.'
    ];
    return messages[_random.nextInt(messages.length)];
  }

  int get freezePoints => _freezePoints;

  void resetFreeze() {
    _freezePoints = 0;
  }
}