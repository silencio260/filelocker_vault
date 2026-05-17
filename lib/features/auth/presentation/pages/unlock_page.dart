import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/pin_input_widget.dart';

class UnlockPage extends StatelessWidget {
  const UnlockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<AuthBloc>()..add(const AuthCheckFirstTimeEvent()),
      child: const _UnlockView(),
    );
  }
}

class _UnlockView extends StatefulWidget {
  const _UnlockView();

  @override
  State<_UnlockView> createState() => _UnlockViewState();
}

class _UnlockViewState extends State<_UnlockView> {
  final _controller = PinInputController();
  Timer? _lockoutTimer;
  Duration _remainingLockout = Duration.zero;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startLockoutTimer(Duration remaining) {
    _remainingLockout = remaining;
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remainingLockout.inSeconds > 0) {
          _remainingLockout -= const Duration(seconds: 1);
        } else {
          t.cancel();
          _remainingLockout = Duration.zero;
          _errorText = null;
        }
      });
    });
  }

  void _tryBiometric(BuildContext context) {
    context.read<AuthBloc>().add(const AuthBiometricEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnlockRequired) {
          if (state.auth.biometricEnabled) {
              final bloc = context.read<AuthBloc>();
              Future.microtask(() => bloc.add(const AuthBiometricEvent()));
          }
        } else if (state is AuthSuccess) {
          _lockoutTimer?.cancel();
          Navigator.of(context).pushReplacementNamed(AppRoutes.vaultHome);
        } else if (state is AuthLockedOut) {
          _controller.clear();
          setState(() => _errorText = null);
          _startLockoutTimer(state.lockout.remainingLockout);
        } else if (state is AuthFailure) {
          _controller.clear();
          setState(() => _errorText =
              'Wrong PIN. ${state.lockout.attemptsRemaining} attempts left.');
        } else if (state is AuthError) {
          _controller.clear();
          setState(() => _errorText = state.message);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64),
                  const SizedBox(height: 24),
                  Text('Enter PIN',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 40),
                  if (_remainingLockout.inSeconds > 0) ...[
                    Icon(Icons.timer_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Too many attempts.\nTry again in ${_remainingLockout.inSeconds}s',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ] else ...[
                    PinInputWidget(
                      controller: _controller,
                      onComplete: (pin) =>
                          context.read<AuthBloc>().add(AuthVerifyPinEvent(pin)),
                      errorText: _errorText,
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final auth =
                            state is AuthUnlockRequired ? state.auth : null;
                        if (auth?.biometricEnabled == true) {
                          return TextButton.icon(
                            onPressed: () => _tryBiometric(context),
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Use biometric'),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
