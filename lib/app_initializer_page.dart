import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/domain/usecases/check_first_time_usecase.dart';
import 'core/usecase/base_usecase.dart';

class AppInitializerPage extends StatefulWidget {
  const AppInitializerPage({super.key});

  @override
  State<AppInitializerPage> createState() => _AppInitializerPageState();
}

class _AppInitializerPageState extends State<AppInitializerPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final checkFirstTime = GetIt.I<CheckFirstTimeUseCase>();
    final result = await checkFirstTime(NoParams.instance);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
        _initialize();
      },
      (isFirstTime) {
        if (isFirstTime) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.pinSetup);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.unlock);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
