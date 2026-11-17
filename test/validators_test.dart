import 'package:flutter_test/flutter_test.dart';
import 'package:taller_final/core/validators.dart';

void main() {
  test('login accepts a username and rejects a short password', () {
    expect(Validators.loginIdentifier('demo'), isNull);
    expect(Validators.loginIdentifier('demo@ecommerce.test'), isNull);
    expect(Validators.loginIdentifier('mal@correo'), isNotNull);
    expect(Validators.loginIdentifier(''), isNotNull);
    expect(Validators.loginPassword('12345'), isNotNull);
    expect(Validators.loginPassword('123456'), isNull);
  });

  test('register requires 8 characters and matching passwords', () {
    expect(Validators.password('1234567'), isNotNull);
    expect(Validators.password('12345678'), isNull);
    expect(Validators.confirmPassword('12345678', 'otra'), isNotNull);
    expect(Validators.confirmPassword('12345678', '12345678'), isNull);
    expect(Validators.username('ab'), isNotNull);
    expect(Validators.username('ana.perez'), isNull);
    expect(Validators.username('ana perez'), isNotNull);
    expect(Validators.email('demo@ecommerce.test'), isNull);
  });

  test('extractToken reads a token from a reset link', () {
    expect(
      Validators.extractToken('https://tienda.app/reset?token=abc123'),
      'abc123',
    );
    expect(Validators.extractToken('  abc123  '), 'abc123');
    expect(Validators.extractToken(''), '');
  });
}
