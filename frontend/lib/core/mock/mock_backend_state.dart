import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/network/problem_details.dart';
import 'package:frontend/features/auth/data/models/auth_models.dart';
import 'package:frontend/features/chart/data/models/stats_models.dart';
import 'package:frontend/features/children/data/models/child_models.dart';
import 'package:frontend/features/map/data/models/map_models.dart';
import 'package:frontend/features/rewards/data/models/reward_models.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';

class _MockChildProgress {
  _MockChildProgress({
    required this.child,
    Set<String>? completedStageIds,
    Map<String, int>? hintsUsedPerStage,
    Map<String, int>? attemptsPerStage,
    List<TransactionDto>? transactions,
    List<ChildBadgeDto>? badges,
    Map<String, int>? dailyFlames,
  })  : completedStageIds = completedStageIds ?? {},
        hintsUsedPerStage = hintsUsedPerStage ?? {},
        attemptsPerStage = attemptsPerStage ?? {},
        transactions = transactions ?? [],
        badges = badges ?? [],
        dailyFlames = dailyFlames ?? {};

  ChildDto child;
  final Set<String> completedStageIds;
  final Map<String, int> hintsUsedPerStage;
  final Map<String, int> attemptsPerStage;
  final List<TransactionDto> transactions;
  final List<ChildBadgeDto> badges;
  final Map<String, int> dailyFlames;
}

/// Shared stateful mock backend matching `docs/README.md` & `docs/swagger.json`.
///
/// Designed so seeded data can be replaced directly from `docs/samples/*.json`
/// once real backend samples are added.
class MockBackendState {
  MockBackendState() {
    _seedInitialData();
  }

  static const String level1Id = '11111111-1111-1111-1111-111111111101';
  static const String stage1Id = '22222222-2222-2222-2222-222222222201';
  static const String stage2Id = '22222222-2222-2222-2222-222222222202';
  static const String stage3Id = '22222222-2222-2222-2222-222222222203';
  static const String stage4Id = '22222222-2222-2222-2222-222222222204';

  String _email = 'demo@codekids.com';
  String _password = 'Password123!';
  String _pin = '1234';
  String _language = 'en';
  final String _parentId = '00000000-0000-0000-0000-000000000001';

  final Map<String, _MockChildProgress> _children = {};
  int _idCounter = 10;

  void _seedInitialData() {
    const alexId = '33333333-3333-3333-3333-333333333301';
    _children[alexId] = _MockChildProgress(
      child: const ChildDto(
        id: alexId,
        name: 'Alex',
        age: 10,
        avatarId: 'avatar_robot_blue',
        flames: 120,
        streakDays: 1,
      ),
      transactions: [
        TransactionDto(
          id: '44444444-4444-4444-4444-444444444401',
          amount: 120,
          reason: 'Welcome bonus (Mock mode)',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
      dailyFlames: {
        _dateKey(DateTime.now().toUtc()): 120,
      },
    );
  }

  AuthResponseDto register(RegisterRequestDto dto) {
    if (dto.email.trim().toLowerCase() == _email && _children.isNotEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.conflict,
        statusCode: 409,
        problemDetails: ProblemDetails(
          status: 409,
          title: 'Conflict',
          detail: 'An account with this email already exists.',
        ),
      );
    }
    _email = dto.email.trim().toLowerCase();
    _password = dto.password;
    _pin = dto.pin;
    _language = dto.language;
    _children.clear();

    return AuthResponseDto(
      token: 'mock-jwt-token-$_parentId',
      expiresInSeconds: 86400,
      parent: ParentDto(id: _parentId, email: _email, language: _language),
    );
  }

  AuthResponseDto login(LoginRequestDto dto) {
    if (dto.email.trim().toLowerCase() != _email || dto.password != _password) {
      throw const ApiException(
        kind: ApiErrorKind.unauthorized,
        statusCode: 401,
        problemDetails: ProblemDetails(
          status: 401,
          title: 'Unauthorized',
          detail: 'Invalid email or password.',
        ),
      );
    }
    return AuthResponseDto(
      token: 'mock-jwt-token-$_parentId',
      expiresInSeconds: 86400,
      parent: ParentDto(id: _parentId, email: _email, language: _language),
    );
  }

  VerifyPinResponseDto verifyPin(VerifyPinRequestDto dto) {
    if (dto.pin != _pin) {
      throw const ApiException(
        kind: ApiErrorKind.unauthorized,
        statusCode: 401,
        problemDetails: ProblemDetails(
          status: 401,
          title: 'Unauthorized',
          detail: 'Invalid parent PIN.',
        ),
      );
    }
    return const VerifyPinResponseDto(
      token: 'mock-parent-area-token',
      expiresInSeconds: 900,
    );
  }

  List<ChildDto> listChildren() =>
      _children.values.map((e) => e.child).toList();

  ChildDto createChild(CreateChildRequestDto dto) {
    final id = '33333333-3333-3333-3333-3333333333${++_idCounter}';
    final child = ChildDto(
      id: id,
      name: dto.name,
      age: dto.age,
      avatarId: dto.avatarId,
      flames: 0,
      streakDays: 0,
    );
    _children[id] = _MockChildProgress(child: child);
    return child;
  }

  void deleteChild(String childId) {
    if (!_children.containsKey(childId)) {
      throw const ApiException(
        kind: ApiErrorKind.notFound,
        statusCode: 404,
        problemDetails: ProblemDetails(
          status: 404,
          title: 'Not Found',
          detail: 'Child profile not found.',
        ),
      );
    }
    _children.remove(childId);
  }

  _MockChildProgress _requireChild(String childId) {
    final entry = _children[childId];
    if (entry == null) {
      throw const ApiException(
        kind: ApiErrorKind.notFound,
        statusCode: 404,
        problemDetails: ProblemDetails(
          status: 404,
          title: 'Not Found',
          detail: 'Child profile not found.',
        ),
      );
    }
    return entry;
  }

  MapResponseDto getMap(String childId) {
    final progress = _requireChild(childId);
    final completed = progress.completedStageIds;

    StageStatus statusFor(int index, String id, String? previousId) {
      if (completed.contains(id)) return StageStatus.completed;
      if (index == 0 || (previousId != null && completed.contains(previousId))) {
        return StageStatus.available;
      }
      return StageStatus.locked;
    }

    final stages = [
      MapStageDto(
        id: stage1Id,
        order: 1,
        type: 'Explanation',
        title: 'Welcome to Python',
        rewardFlames: 10,
        status: statusFor(0, stage1Id, null),
        flamesEarned: completed.contains(stage1Id) ? 10 : 0,
        attempts: progress.attemptsPerStage[stage1Id] ?? 0,
      ),
      MapStageDto(
        id: stage2Id,
        order: 2,
        type: 'Quiz',
        title: 'First Commands Quiz',
        rewardFlames: 25,
        status: statusFor(1, stage2Id, stage1Id),
        flamesEarned: completed.contains(stage2Id) ? 25 : 0,
        attempts: progress.attemptsPerStage[stage2Id] ?? 0,
      ),
      MapStageDto(
        id: stage3Id,
        order: 3,
        type: 'Quiz',
        title: 'Variables and Numbers',
        rewardFlames: 25,
        status: statusFor(2, stage3Id, stage2Id),
        flamesEarned: completed.contains(stage3Id) ? 25 : 0,
        attempts: progress.attemptsPerStage[stage3Id] ?? 0,
      ),
      MapStageDto(
        id: stage4Id,
        order: 4,
        type: 'Final',
        title: 'Level 1 Final Test',
        rewardFlames: 60,
        status: statusFor(3, stage4Id, stage3Id),
        flamesEarned: completed.contains(stage4Id) ? 60 : 0,
        attempts: progress.attemptsPerStage[stage4Id] ?? 0,
      ),
    ];

    return MapResponseDto(
      childId: progress.child.id,
      childName: progress.child.name,
      flames: progress.child.flames,
      streakDays: progress.child.streakDays,
      levels: [
        MapLevelDto(
          id: level1Id,
          order: 1,
          title: 'Instructions',
          theme: 'space_python',
          isLocked: false,
          stages: stages,
        ),
      ],
    );
  }

  StageDetailDto getStageDetail(String stageId, String childId) {
    final map = getMap(childId);
    final stage = map.levels
        .expand((l) => l.stages)
        .where((s) => s.id == stageId)
        .firstOrNull;
    if (stage == null) {
      throw const ApiException(
        kind: ApiErrorKind.notFound,
        statusCode: 404,
        problemDetails: ProblemDetails(
          status: 404,
          title: 'Not Found',
          detail: 'Stage not found.',
        ),
      );
    }
    if (stage.status == StageStatus.locked) {
      throw const ApiException(
        kind: ApiErrorKind.forbidden,
        statusCode: 403,
        problemDetails: ProblemDetails(
          status: 403,
          title: 'Forbidden',
          detail: 'Complete previous stages to unlock this stage.',
        ),
      );
    }
    return _stageCatalog[stageId]!;
  }

  HintResponseDto buyHint(String stageId, HintRequestDto dto) {
    final progress = _requireChild(dto.childId);
    final stage = _stageCatalog[stageId];
    if (stage == null) {
      throw const ApiException(kind: ApiErrorKind.notFound, statusCode: 404);
    }
    final question = stage.questions
        .where((q) => q.id == dto.questionId)
        .firstOrNull;
    if (question == null) {
      throw const ApiException(kind: ApiErrorKind.notFound, statusCode: 404);
    }

    final used = progress.hintsUsedPerStage[stageId] ?? 0;
    final cost = AppConfig.baseHintPrice + (used * AppConfig.hintPriceStep);
    if (progress.child.flames < cost) {
      throw const ApiException(
        kind: ApiErrorKind.conflict,
        statusCode: 409,
        problemDetails: ProblemDetails(
          status: 409,
          title: 'Insufficient Flames',
          detail: 'Not enough flames to purchase this hint.',
        ),
      );
    }

    final newFlames = progress.child.flames - cost;
    progress.hintsUsedPerStage[stageId] = used + 1;
    progress.child = progress.child.copyWith(flames: newFlames);
    progress.transactions.insert(
      0,
      TransactionDto(
        id: 'tx-${++_idCounter}',
        amount: -cost,
        reason: 'Hint used in ${stage.title}',
        createdAt: DateTime.now().toUtc(),
      ),
    );

    return HintResponseDto(
      hintText: question.hintText ?? 'Look closely at each Python instruction!',
      cost: cost,
      flamesLeft: newFlames,
    );
  }

  CompleteStageResponseDto completeStage(
    String stageId,
    CompleteStageRequestDto dto,
  ) {
    final progress = _requireChild(dto.childId);
    final stage = _stageCatalog[stageId];
    if (stage == null) {
      throw const ApiException(kind: ApiErrorKind.notFound, statusCode: 404);
    }

    final alreadyCompleted = progress.completedStageIds.contains(stageId);
    progress.attemptsPerStage[stageId] =
        (progress.attemptsPerStage[stageId] ?? 0) + dto.attempts;

    if (alreadyCompleted) {
      return CompleteStageResponseDto(
        flamesEarned: 0,
        streakBonus: 0,
        flamesTotal: progress.child.flames,
        streakDays: progress.child.streakDays,
        newBadges: const [],
      );
    }

    progress.completedStageIds.add(stageId);
    final earned = stage.rewardFlames;
    final newStreak = progress.child.streakDays == 0 ? 1 : progress.child.streakDays;
    final streakBonus = progress.completedStageIds.length == 1 ? 5 : 0;
    final newTotal = progress.child.flames + earned + streakBonus;

    progress.child = progress.child.copyWith(
      flames: newTotal,
      streakDays: newStreak,
      lastActiveDate: DateTime.now().toUtc(),
    );

    final today = _dateKey(DateTime.now().toUtc());
    progress.dailyFlames[today] =
        (progress.dailyFlames[today] ?? 0) + earned + streakBonus;

    progress.transactions.insert(
      0,
      TransactionDto(
        id: 'tx-${++_idCounter}',
        amount: earned + streakBonus,
        reason: 'Completed ${stage.title}',
        createdAt: DateTime.now().toUtc(),
      ),
    );

    final awardedBadges = <BadgeAwardDto>[];
    void award(String code, String name, String condition) {
      if (progress.badges.any((b) => b.condition == condition || b.name == name)) {
        return;
      }
      final now = DateTime.now().toUtc();
      progress.badges.add(
        ChildBadgeDto(
          id: 'badge-$code',
          name: name,
          condition: condition,
          iconUrl: code,
          earnedAt: now,
        ),
      );
      awardedBadges.add(
        BadgeAwardDto(
          id: 'badge-$code',
          name: name,
          condition: condition,
          iconUrl: code,
        ),
      );
    }

    if (progress.completedStageIds.length == 1) {
      award('FIRST_STAGE', 'First Step', 'FIRST_STAGE');
    }
    if (stage.type == StageType.quiz) {
      award('FIRST_QUIZ', 'Quiz Whiz', 'FIRST_QUIZ');
    }
    if (stageId == stage4Id) {
      award('LEVEL_1_COMPLETE', 'Level 1 Champion', 'LEVEL_1_COMPLETE');
    }

    final unlockedStageId = switch (stageId) {
      stage1Id => stage2Id,
      stage2Id => stage3Id,
      stage3Id => stage4Id,
      _ => null,
    };

    return CompleteStageResponseDto(
      flamesEarned: earned,
      streakBonus: streakBonus,
      flamesTotal: newTotal,
      streakDays: newStreak,
      unlockedStageId: unlockedStageId,
      unlockedLevelId: null,
      newBadges: awardedBadges,
    );
  }

  RewardResponseDto getRewards(String childId) {
    final progress = _requireChild(childId);
    final now = DateTime.now().toUtc();
    final activity = List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      final key = _dateKey(day);
      final flames = progress.dailyFlames[key] ?? 0;
      return DayActivityDto(
        date: key,
        flamesEarned: flames,
        stagesCompleted: flames > 0 ? 1 : 0,
        isActive: flames > 0,
      );
    });

    return RewardResponseDto(
      flames: progress.child.flames,
      streakDays: progress.child.streakDays,
      sevenDayActivity: activity,
      transactions: List.unmodifiable(progress.transactions),
      badges: List.unmodifiable(progress.badges),
    );
  }

  StatsResponseDto getStats(String childId) {
    final progress = _requireChild(childId);
    final now = DateTime.now().toUtc();
    final flamesPerDay = List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      final key = _dateKey(day);
      return DailyFlamesDto(
        date: key,
        flames: progress.dailyFlames[key] ?? 0,
      );
    });

    final completedCount = progress.completedStageIds.length;
    const totalStages = 4;
    return StatsResponseDto(
      childId: progress.child.id,
      childName: progress.child.name,
      totalCompletedStages: completedCount,
      totalFlames: progress.child.flames,
      currentStreakDays: progress.child.streakDays,
      flamesPerDay: flamesPerDay,
      levelProgress: [
        LevelProgressDto(
          levelId: level1Id,
          levelOrder: 1,
          levelTitle: 'Instructions',
          totalStages: totalStages,
          completedStages: completedCount,
          completionPercentage: (completedCount / totalStages) * 100,
          isCompleted: completedCount >= totalStages,
        ),
      ],
    );
  }

  static String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static final Map<String, StageDetailDto> _stageCatalog = {
    stage1Id: StageDetailDto.fromJson({
      'id': stage1Id,
      'levelId': level1Id,
      'order': 1,
      'type': 'Explanation',
      'title': 'Welcome to Python',
      'rewardFlames': 10,
      'content': {
        'title': 'What is an instruction?',
        'text':
            'Instructions are the basic actions of a computer program. In Python, print() displays a message on the screen.',
        'code': 'print("Hello, CodeKids!")',
      },
      'questions': const [],
    }),
    stage2Id: StageDetailDto.fromJson({
      'id': stage2Id,
      'levelId': level1Id,
      'order': 2,
      'type': 'Quiz',
      'title': 'First Commands Quiz',
      'rewardFlames': 25,
      'questions': [
        {
          'id': '55555555-5555-5555-5555-555555555501',
          'type': 'Mcq',
          'text': 'Which command displays words on the computer screen in Python?',
          'options': ['print()', 'input()', 'show()', 'write()'],
          'answer': {'correct': 'print()'},
          'hintText': 'Think of a printer putting words onto paper.',
          'explanationText': 'In Python, print() sends output to the terminal or screen.',
        },
        {
          'id': '55555555-5555-5555-5555-555555555502',
          'type': 'TrueFalse',
          'text': 'Python runs code from top to bottom, one instruction at a time.',
          'options': ['True', 'False'],
          'answer': {'correct': 'True'},
          'hintText': 'Imagine reading a comic book panel by panel from top to bottom.',
          'explanationText': 'Programs execute sequentially line-by-line starting at the first line.',
        },
        {
          'id': '55555555-5555-5555-5555-555555555503',
          'type': 'Order',
          'text': 'Arrange these lines so the program greets the player, asks if ready, and finishes.',
          'options': [
            "print('Welcome, coder!')",
            "print('Are you ready?')",
            "print('Mission complete!')",
          ],
          'answer': {
            'order': [
              "print('Welcome, coder!')",
              "print('Are you ready?')",
              "print('Mission complete!')",
            ],
          },
          'hintText': 'First say welcome, then ask the question, then say mission complete.',
          'explanationText': 'Sequential order means the greeting must come before the ending.',
        },
        {
          'id': '55555555-5555-5555-5555-555555555504',
          'type': 'FillBlank',
          'text': "Complete the code to print hi: ____('Hi!')",
          'options': ['print', 'show', 'say', 'echo'],
          'answer': {'correct': 'print'},
          'hintText': 'The keyword is the standard 5-letter Python display function.',
          'explanationText': "We write print('Hi!') to call the print function.",
        },
      ],
    }),
    stage3Id: StageDetailDto.fromJson({
      'id': stage3Id,
      'levelId': level1Id,
      'order': 3,
      'type': 'Quiz',
      'title': 'Variables and Numbers',
      'rewardFlames': 25,
      'questions': [
        {
          'id': '55555555-5555-5555-5555-555555555505',
          'type': 'Mcq',
          'text': 'What does print(5 + 3) display?',
          'options': ['5', '8', '53', 'Error'],
          'answer': {'correct': '8'},
          'hintText': 'The + sign adds the two numbers together.',
          'explanationText': 'Python evaluates 5 + 3 to 8 before printing it.',
        },
        {
          'id': '55555555-5555-5555-5555-555555555506',
          'type': 'TrueFalse',
          'text': 'A variable can store a number or a word for later use.',
          'options': ['True', 'False'],
          'answer': {'correct': 'True'},
          'hintText': 'Think of a variable like a labeled storage box.',
          'explanationText': 'Variables hold values like score = 10 or name = "Alex".',
        },
        {
          'id': '55555555-5555-5555-5555-555555555507',
          'type': 'Order',
          'text': 'Order these lines to create a score variable and print it.',
          'options': [
            'score = 10',
            'score = score + 5',
            'print(score)',
          ],
          'answer': {
            'order': [
              'score = 10',
              'score = score + 5',
              'print(score)',
            ],
          },
          'hintText': 'You must create score before adding to it or printing it.',
          'explanationText': 'Variables must be defined before they are used.',
        },
        {
          'id': '55555555-5555-5555-5555-555555555508',
          'type': 'FillBlank',
          'text': 'Assign 12 to coins: coins ____ 12',
          'options': ['=', '==', ':', '->'],
          'answer': {'correct': '='},
          'hintText': 'A single equals sign stores a value into a variable.',
          'explanationText': 'In Python, = assigns a value to a variable.',
        },
      ],
    }),
    stage4Id: StageDetailDto.fromJson({
      'id': stage4Id,
      'levelId': level1Id,
      'order': 4,
      'type': 'Final',
      'title': 'Level 1 Final Test',
      'rewardFlames': 60,
      'questions': [
        {
          'id': '55555555-5555-5555-5555-555555555509',
          'type': 'Mcq',
          'text': 'Which line correctly prints Hello?',
          'options': [
            'print("Hello")',
            'Print("Hello")',
            'echo("Hello")',
            'print[Hello]',
          ],
          'answer': {'correct': 'print("Hello")'},
          'hintText': 'Python function names are lowercase and use parentheses ().',
          'explanationText': 'print("Hello") uses lowercase print and parentheses.',
        },
        {
          'id': '55555555-5555-5555-5555-555555555510',
          'type': 'TrueFalse',
          'text': 'In Python, "5" + "3" gives the number 8.',
          'options': ['True', 'False'],
          'answer': {'correct': 'False'},
          'hintText': 'Quotes around digits turn them into text strings.',
          'explanationText': '"5" and "3" are strings, so "5" + "3" produces "53".',
        },
        {
          'id': '55555555-5555-5555-5555-555555555511',
          'type': 'Order',
          'text': 'Arrange the rocket launch countdown!',
          'options': [
            'print("3")',
            'print("2")',
            'print("1")',
            'print("Liftoff!")',
          ],
          'answer': {
            'order': [
              'print("3")',
              'print("2")',
              'print("1")',
              'print("Liftoff!")',
            ],
          },
          'hintText': 'Count down from 3 to 1, then launch!',
          'explanationText': 'Instructions run in the exact order they are written.',
        },
        {
          'id': '55555555-5555-5555-5555-555555555512',
          'type': 'FillBlank',
          'text': 'Print the variable name: ____(name)',
          'options': ['print', 'show', 'display', 'text'],
          'answer': {'correct': 'print'},
          'hintText': 'Use the standard Python output command.',
          'explanationText': 'print(name) displays the value stored in name.',
        },
      ],
    }),
  };
}
