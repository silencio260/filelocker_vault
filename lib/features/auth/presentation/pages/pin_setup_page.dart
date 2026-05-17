import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/pin_input_widget.dart';

class PinSetupPage extends StatelessWidget {
  const PinSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<AuthBloc>(),
      child: const _PinSetupView(),
    );
  }
}

class _PinSetupView extends StatefulWidget {
  const _PinSetupView();

  @override
  State<_PinSetupView> createState() => _PinSetupViewState();
}

class _PinSetupViewState extends State<_PinSetupView> {
  final _controller = PinInputController();
  String _title = 'Create your PIN';
  String _subtitle = 'Enter a 6-digit PIN to secure your vault';
  String? _errorText;
  bool _isConfirming = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPinComplete(BuildContext context, String pin) {
    if (!_isConfirming) {
      context.read<AuthBloc>().add(AuthSetupPinEvent(pin));
    } else {
      context.read<AuthBloc>().add(AuthConfirmPinEvent(pin));
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPinSetupStep2) {
          setState(() {
            _isConfirming = true;
            _title = 'Confirm your PIN';
            _subtitle = 'Enter your PIN again to confirm';
            _errorText = null;
          });
        } else if (state is AuthPinMismatch) {
          setState(() {
            _errorText = 'PINs do not match. Try again.';
            _isConfirming = false;
            _title = 'Create your PIN';
            _subtitle = 'Enter a 6-digit PIN to secure your vault';
          });
        } else if (state is AuthSuccess) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.biometricSetup);
        } else if (state is AuthError) {
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
                  const Icon(Icons.lock_outline, size: 64),
                  const SizedBox(height: 24),
                  Text(_title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(_subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  PinInputWidget(
                    controller: _controller,
                    onComplete: (pin) => _onPinComplete(context, pin),
                    errorText: _errorText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
