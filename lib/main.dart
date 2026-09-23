import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/pocki_theme.dart';
import 'data/datasources/firebase/firebase_data_source.dart';
import 'data/datasources/local/local_cache_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'data/repositories/todo_repository_impl.dart';
import 'domain/usecases/additional_amount_usecases.dart';
import 'domain/usecases/auth_usecases.dart';
import 'domain/usecases/expense_usecases.dart';
import 'domain/usecases/todo_usecases.dart';
import 'firebase_options.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/pages/login_screen.dart';
import 'presentation/auth/pages/register_screen.dart';
import 'presentation/auth/pages/splash_screen.dart';
import 'presentation/auth/pages/welcome_screen.dart';
import 'presentation/expenses/bloc/expense_bloc.dart';
import 'presentation/navigation/main_navigation_screen.dart';
import 'presentation/profile/bloc/profile_bloc.dart';
import 'presentation/profile/pages/settings_screen.dart';
import 'presentation/todos/bloc/todo_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  // Initialize Data Sources
  final firebaseDataSource = FirebaseDataSource();
  final localCacheDataSource = LocalCacheDataSource();

  // Initialize Repositories
  final authRepository = AuthRepositoryImpl(firebaseDataSource, localCacheDataSource);
  final expenseRepository = ExpenseRepositoryImpl(firebaseDataSource, localCacheDataSource);
  final todoRepository = TodoRepositoryImpl(firebaseDataSource, localCacheDataSource);

  // Initialize Use Cases
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final getInitialUserUseCase = GetInitialUserUseCase(authRepository);
  final updateUserProfileUseCase = UpdateUserProfileUseCase(authRepository);

  final getExpensesStreamUseCase = GetExpensesStreamUseCase(expenseRepository);
  final addExpenseUseCase = AddExpenseUseCase(expenseRepository);
  final deleteExpenseUseCase = DeleteExpenseUseCase(expenseRepository);

  final getFixedExpensesStreamUseCase = GetFixedExpensesStreamUseCase(expenseRepository);
  final addFixedExpenseUseCase = AddFixedExpenseUseCase(expenseRepository);
  final updateFixedExpenseUseCase = UpdateFixedExpenseUseCase(expenseRepository);
  final deleteFixedExpenseUseCase = DeleteFixedExpenseUseCase(expenseRepository);

  final getAdditionalAmountsStreamUseCase = GetAdditionalAmountsStreamUseCase(expenseRepository);
  final addAdditionalAmountUseCase = AddAdditionalAmountUseCase(expenseRepository);
  final updateAdditionalAmountUseCase = UpdateAdditionalAmountUseCase(expenseRepository);
  final deleteAdditionalAmountUseCase = DeleteAdditionalAmountUseCase(expenseRepository);

  final getTodosStreamUseCase = GetTodosStreamUseCase(todoRepository);
  final addTodoUseCase = AddTodoUseCase(todoRepository);
  final updateTodoUseCase = UpdateTodoUseCase(todoRepository);
  final deleteTodoUseCase = DeleteTodoUseCase(todoRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
            getInitialUserUseCase: getInitialUserUseCase,
          )..add(AuthCheckRequestedEvent()),
        ),
        BlocProvider<ExpenseBloc>(
          create: (_) => ExpenseBloc(
            getExpensesStreamUseCase: getExpensesStreamUseCase,
            addExpenseUseCase: addExpenseUseCase,
            deleteExpenseUseCase: deleteExpenseUseCase,
            getFixedExpensesStreamUseCase: getFixedExpensesStreamUseCase,
            addFixedExpenseUseCase: addFixedExpenseUseCase,
            updateFixedExpenseUseCase: updateFixedExpenseUseCase,
            deleteFixedExpenseUseCase: deleteFixedExpenseUseCase,
            getAdditionalAmountsStreamUseCase: getAdditionalAmountsStreamUseCase,
            addAdditionalAmountUseCase: addAdditionalAmountUseCase,
            updateAdditionalAmountUseCase: updateAdditionalAmountUseCase,
            deleteAdditionalAmountUseCase: deleteAdditionalAmountUseCase,
          ),
        ),
        BlocProvider<TodoBloc>(
          create: (_) => TodoBloc(
            getTodosStreamUseCase: getTodosStreamUseCase,
            addTodoUseCase: addTodoUseCase,
            updateTodoUseCase: updateTodoUseCase,
            deleteTodoUseCase: deleteTodoUseCase,
          ),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
            updateUserProfileUseCase: updateUserProfileUseCase,
          ),
        ),
      ],
      child: const PockiApp(),
    ),
  );
}

class PockiApp extends StatelessWidget {
  const PockiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocki 👛',
      debugShowCheckedModeBanner: false,
      theme: PockiTheme.lightTheme,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthenticatedState) {
            return const MainNavigationScreen(initialIndex: 0);
          }
          if (state is AuthLoadingState || state is AuthInitialState) {
            return const SplashScreen();
          }
          return const WelcomeScreen();
        },
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/welcome':
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const MainNavigationScreen(initialIndex: 0),
            );
          case '/expenses':
            return MaterialPageRoute(
              builder: (_) => const MainNavigationScreen(initialIndex: 1),
            );
          case '/todos':
          case '/nextup':
            return MaterialPageRoute(
              builder: (_) => const MainNavigationScreen(initialIndex: 2),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => const MainNavigationScreen(initialIndex: 3),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const MainNavigationScreen(initialIndex: 0),
            );
        }
      },
    );
  }
}
