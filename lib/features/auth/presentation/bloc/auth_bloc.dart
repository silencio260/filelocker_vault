import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../../domain/entities/lockout_state_entity.dart';
import '../../domain/usecases/authenticate_biometric_usecase.dart';
import '../../domain/usecases/check_first_time_usecase.dart';
import '../../domain/usecases/enable_biometric_usecase.dart';
import '../../domain/usecases/get_auth_state_usecase.dart';
import '../../domain/usecases/register_failed_attempt_usecase.dart';
import '../../domain/usecases/setup_pin_usecase.dart';
import '../../domain/usecases/verify_pin_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckFirstTimeUseCase checkFirstTime;
  final SetupPinUseCase setupPin;
  final VerifyPinUseCase verifyPin;
  final AuthenticateBiometricUseCase authenticateBiometric;
  final EnableBiometricUseCase enableBiometric;
  final GetAuthStateUseCase getAuthState;
  final RegisterFailedAttemptUseCase registerFailedAttempt;

  AuthBloc({
    required this.checkFirstTime,
    required this.setupPin,
    required this.verifyPin,
    required this.authenticateBiometric,
    required this.enableBiometric,
    required this.getAuthState,
    required this.registerFailedAttempt,
  }) : super(const AuthInitial()) {
    on<AuthCheckFirstTimeEvent>(_onCheckFirstTime);
    on<AuthSetupPinEvent>(_onSetupPin);
    on<AuthConfirmPinEvent>(_onConfirmPin);
    on<AuthVerifyPinEvent>(_onVerifyPin);
    on<AuthBiometricEvent>(_onBiometric);
    on<AuthEnableBiometricEvent>(_onEnableBiometric);
    on<AuthRegisterFailedAttemptEvent>(_onRegisterFailedAttempt);
  }

  static const _emptyLockout = LockoutStateEntity(
    isLockedOut: false,
    remainingLockout: Duration.zero,
    attemptsRemaining: 5,
    protectionEnabled: true,
  );

  Future<void> _onCheckFirstTime(
      AuthCheckFirstTimeEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await checkFirstTime(NoParams.instance);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (isFirst) async {
        if (isFirst) {
          emit(const AuthFirstTime());
        } else {
          final authResult = await getAuthState(NoParams.instance);
          authResult.fold(
            (f) => emit(AuthError(f.message)),
            (auth) => emit(AuthUnlockRequired(
                auth: auth, lockout: _emptyLockout)),
          );
        }
      },
    );
  }

  Future<void> _onSetupPin(
      AuthSetupPinEvent event, Emitter<AuthState> emit) async {
    emit(AuthPinSetupStep2(event.pin));
  }

  Future<void> _onConfirmPin(
      AuthConfirmPinEvent event, Emitter<AuthState> emit) async {
    final current = state;
    if (current is! AuthPinSetupStep2) return;

    if (event.pin != current.firstPin) {
      emit(const AuthPinMismatch());
      return;
    }

    emit(const AuthLoading());
    final result = await setupPin(SetupPinParams(event.pin));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (success) =>
          success ? emit(const AuthSuccess()) : emit(const AuthPinMismatch()),
    );
  }

  Future<void> _onVerifyPin(
      AuthVerifyPinEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await verifyPin(VerifyPinParams(event.pin));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (correct) async {
        if (correct) {
          emit(const AuthSuccess());
        } else {
          final failResult = await registerFailedAttempt(NoParams.instance);
          failResult.fold(
            (f) => emit(AuthError(f.message)),
            (lockout) {
              if (lockout.isLockedOut) {
                emit(AuthLockedOut(lockout));
              } else {
                emit(AuthFailure(
                    message: 'Incorrect PIN', lockout: lockout));
              }
            },
          );
        }
      },
    );
  }

  Future<void> _onBiometric(
      AuthBiometricEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authenticateBiometric(NoParams.instance);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (success) {
        if (success) {
          emit(const AuthSuccess());
        } else {
          emit(const AuthError('Biometric authentication failed'));
        }
      },
    );
  }

  Future<void> _onEnableBiometric(
      AuthEnableBiometricEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await enableBiometric(NoParams.instance);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (success) => success
          ? emit(const AuthBiometricEnabled())
          : emit(const AuthError('Could not enable biometric')),
    );
  }

  Future<void> _onRegisterFailedAttempt(
      AuthRegisterFailedAttemptEvent event, Emitter<AuthState> emit) async {
    final result = await registerFailedAttempt(NoParams.instance);
    result.fold(
      (f) => null,
      (lockout) {
        if (lockout.isLockedOut) emit(AuthLockedOut(lockout));
      },
    );
  }
}
