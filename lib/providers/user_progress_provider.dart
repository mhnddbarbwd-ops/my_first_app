import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nafahat/models/user_progress.dart';
import 'package:nafahat/models/challenge_model.dart';

class UserProgressProvider extends ChangeNotifier {
  Box<UserProgress>? _progressBox;
  Box<ChallengeModel>? _challengeBox;
  UserProgress? _progress;

  UserProgressProvider() {
    _progressBox = Hive.box<UserProgress>('userProgress');
    _challengeBox = Hive.box<ChallengeModel>('challenges');
    _progress = _progressBox?.get('main', defaultValue: UserProgress());
    _initializeChallenges();
  }

  UserProgress? get progress => _progress;
  List<ChallengeModel> get challenges => _challengeBox?.values.toList() ?? [];

  void _initializeChallenges() {
    if (_challengeBox?.isEmpty ?? true) {
      final defaultChallenges = [
        ChallengeModel(id: '1', title: 'قارئ مبتدئ', description: 'اقرأ 10 صفحات', targetValue: 10, icon: 'auto_stories'),
        ChallengeModel(id: '2', title: 'قارئ نشط', description: 'اقرأ 50 صفحة', targetValue: 50, icon: 'menu_book'),
        ChallengeModel(id: '3', title: 'قارئ متقدم', description: 'اقرأ 100 صفحة', targetValue: 100, icon: 'library_books'),
        ChallengeModel(id: '4', title: 'المثابر', description: 'حافظ على Streak 7 أيام', targetValue: 7, icon: 'local_fire_department'),
        ChallengeModel(id: '5', title: 'الملتزم', description: 'حافظ على Streak 30 يوم', targetValue: 30, icon: 'whatshot'),
      ];
      for (var challenge in defaultChallenges) {
        _challengeBox?.put(challenge.id, challenge);
      }
    }
  }

  void updateReadPages(int page) {
    _progress?.markPageRead(page);
    _progress?.save();
    _updateChallenges();
    notifyListeners();
  }

  void _updateChallenges() {
    if (_progress == null) return;
    for (var challenge in challenges) {
      if (challenge.isCompleted) continue;
      if (challenge.id == '4' || challenge.id == '5') {
        challenge.currentValue = _progress!.currentStreak;
      } else {
        challenge.currentValue = _progress!.totalPagesRead;
      }
      if (challenge.currentValue >= challenge.targetValue) {
        challenge.isCompleted = true;
        _progress!.totalXP += 50;
        _progress!.save();
      }
      challenge.save();
    }
  }

  void checkDailyStreak() {
    _progress?.checkDailyStreak();
    _progress?.save();
    _updateChallenges();
    notifyListeners();
  }

  void addXP(int xp) {
    _progress?.totalXP = (_progress?.totalXP ?? 0) + xp;
    _progress?.save();
    notifyListeners();
  }
}
