import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/problem_details.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';

void main() {
  group('StageQuestionDto JSON parsing (README examples)', () {
    test('parses Mcq question', () {
      final q = StageQuestionDto.fromJson({
        'id': 'q1',
        'type': 'Mcq',
        'text': 'Which command displays words on the computer screen in Python?',
        'options': ['print()', 'input()', 'show()', 'write()'],
        'answer': {'correct': 'print()'},
        'hintText': 'Think of a printer putting words onto paper.',
        'explanationText':
            'In Python, print() sends output to the terminal or screen.',
      });

      expect(q.type, QuestionType.mcq);
      expect(q.options, ['print()', 'input()', 'show()', 'write()']);
      expect(q.answer, isA<CorrectValueAnswer>());
      expect((q.answer as CorrectValueAnswer).correct, 'print()');
    });

    test('parses TrueFalse question', () {
      final q = StageQuestionDto.fromJson({
        'id': 'q2',
        'type': 'TrueFalse',
        'text':
            'Python runs code from top to bottom, one instruction at a time.',
        'options': ['True', 'False'],
        'answer': {'correct': 'True'},
        'hintText':
            'Imagine reading a comic book panel by panel from top to bottom.',
        'explanationText':
            'Programs execute sequentially line-by-line starting at the first line.',
      });

      expect(q.type, QuestionType.trueFalse);
      expect(q.options, ['True', 'False']);
      expect((q.answer as CorrectValueAnswer).correct, 'True');
    });

    test('parses Order question', () {
      final q = StageQuestionDto.fromJson({
        'id': 'q3',
        'type': 'Order',
        'text':
            'Arrange these lines so the program greets the player, asks if ready, and finishes.',
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
        'hintText':
            'First say welcome, then ask the question, then say mission complete.',
        'explanationText':
            'Sequential order means the greeting must come before the ending.',
      });

      expect(q.type, QuestionType.order);
      expect(q.answer, isA<OrderedValuesAnswer>());
      expect((q.answer as OrderedValuesAnswer).order, [
        "print('Welcome, coder!')",
        "print('Are you ready?')",
        "print('Mission complete!')",
      ]);
    });

    test('parses FillBlank question', () {
      final q = StageQuestionDto.fromJson({
        'id': 'q4',
        'type': 'FillBlank',
        'text': "Complete the code to print hi: ____('Hi!')",
        'options': ['print', 'show', 'say', 'echo'],
        'answer': {'correct': 'print'},
        'hintText':
            'The keyword is the standard 5-letter Python display function.',
        'explanationText': "We write print('Hi!') to call the print function.",
      });

      expect(q.type, QuestionType.fillBlank);
      expect(q.options, ['print', 'show', 'say', 'echo']);
      expect((q.answer as CorrectValueAnswer).correct, 'print');
    });
  });

  group('ProblemDetails parsing', () {
    test('parses RFC 7807 ProblemDetails and validation errors', () {
      final pd = ProblemDetails.fromJson({
        'type': 'https://tools.ietf.org/html/rfc7231#section-6.5.8',
        'title': 'Insufficient Flames',
        'status': 409,
        'detail': 'Not enough flames to purchase this hint.',
        'errors': {
          'Password': ['Password must be at least 8 characters.'],
        },
      });

      expect(pd.status, 409);
      expect(pd.title, 'Insufficient Flames');
      expect(pd.bestMessage, 'Not enough flames to purchase this hint.');
      expect(pd.errors['Password'], ['Password must be at least 8 characters.']);
    });
  });
}
