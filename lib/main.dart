// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:loyalty_app/core/routing/app_router.dart';
// import 'package:loyalty_app/core/routing/routes.dart';
// import 'package:loyalty_app/core/theming/colors.dart';
// import 'package:loyalty_app/features/auth/logic/auth_cubit.dart';
// import 'package:loyalty_app/features/auth/logic/auth_states.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // System UI overlay
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//       systemNavigationBarColor: Colors.white,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ),
//   );

//   runApp(LoyaltyApp(
//     appRouter: AppRouter(),
//   ));
// }

// class LoyaltyApp extends StatelessWidget {
//   final AppRouter appRouter;
//   const LoyaltyApp({super.key, required this.appRouter});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//         designSize: const Size(375, 812),
//         minTextAdapt: true,
//         splitScreenMode: true,
//         builder: (context, child) {
//           return MultiProvider(
//             providers: [
//               ChangeNotifierProvider(create: (_) => AuthProvider()),
//               ChangeNotifierProvider(create: (_) => TransactionProvider()),
//             ],
//             child: Builder(
//               builder: (context) {
//                 return MaterialApp(
//                   debugShowCheckedModeBanner: false,
//                   title: 'نظام نقاط الولاء',
//                   theme: AppTheme.lightTheme,
//                   locale: const Locale('ar'),
//                   supportedLocales: const [
//                     Locale('ar'),
//                     Locale('en'),
//                   ],
//                   localizationsDelegates: const [
//                     GlobalMaterialLocalizations.delegate,
//                     GlobalWidgetsLocalizations.delegate,
//                     GlobalCupertinoLocalizations.delegate,
//                   ],
//                   initialRoute: Routers.login,
//                   onGenerateRoute: appRouter.generateRoute,
//                 );
//               },
//             ),
//           );
//         });
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loyalty_app/core/routing/app_router.dart';
import 'package:loyalty_app/core/routing/routes.dart';
import 'package:loyalty_app/core/theming/colors.dart';
import 'package:loyalty_app/features/admin/logic/qr_history_provider.dart';
import 'package:loyalty_app/features/auth/logic/auth_cubit.dart';
import 'package:loyalty_app/features/auth/logic/auth_states.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // System UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(LoyaltyApp(
    appRouter: AppRouter(),
  ));
}

class LoyaltyApp extends StatelessWidget {
  final AppRouter appRouter;
  const LoyaltyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
            ChangeNotifierProvider(create: (_) => QRHistoryProvider()), // ✅ Added
          ],
          child: Builder(
            builder: (context) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'نظام نقاط الولاء',
                theme: AppTheme.lightTheme,
                locale: const Locale('ar'),
                supportedLocales: const [
                  Locale('ar'),
                  Locale('en'),
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                initialRoute: Routers.login,
                onGenerateRoute: appRouter.generateRoute,
              );
            },
          ),
        );
      },
    );
  }
}