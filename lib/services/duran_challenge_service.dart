import 'package:hive/hive.dart';
import 'package:nafahat/models/quran_challenge.dart';
import 'package:uuid/uuid.dart';

class QuranChallengeService {
  static final QuranChallengeService _instance = QuranChallengeService._internal();
  factory QuranChallengeService() => _instance;
  QuranChallengeService._internal();

  Box<QuranChallenge>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<QuranChallenge>('quranChallenges');
  }

  List<QuranChallenge> get challenges => _box?.values.toList() ?? [];

  Future<void> addChallenge(QuranChallenge challenge) async {
    await _box?.put(challenge.id, challenge);
  }

  Future<void> updateProgress(String id, int pages) async {
    final challenge = _box?.get(id);
    if (challenge != null) {
      challenge.completedPages = pages;
      challenge.streakDays++;
      await challenge.save();
    }
  }

  Future<void> deleteChallenge(String id) async {
    await _box?.delete(id);
  }

  Future<void> resetStreakIfMissed(String id) async {
    final challenge = _box?.get(id);
    if (challenge != null) {
      final now = DateTime.now();
      final lastUpdate = challenge.startDate.add(Duration(days: challenge.streakDays));
      if (now.difference(lastUpdate).inDays > 1) {
        challenge.streakDays = 0;
        await challenge.save();
      }
    }
  }
}