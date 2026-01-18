import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:se2savemanager/bloc/app/app_bloc.dart';
import 'package:se2savemanager/bloc/manager/manager_bloc.dart';
import 'package:se2savemanager/widgets/titlebar.dart';
import 'package:system_theme/system_theme.dart';

import 'save_app_content.dart';

class SaveApp extends StatelessWidget {
  const SaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppBloc()),
        BlocProvider(create: (_) => ManagerBloc()),
      ],
      child: FluentApp(
        title: 'Space Engineers 2 Save Manager',
        theme: .new(
          brightness: .dark,
          // accentColor: SystemTheme.accentColor.accent.toAccentColor(),
          accentColor: SystemAccentColor(
            Color(0xFFe08b0e),
          ).accent.toAccentColor(),
        ),
        debugShowCheckedModeBanner: false,
        home: ScaffoldPage(
          padding: .only(top: 0),
          content: Column(children: [SaveAppTitleBar(), SaveAppContent()]),
        ),
      ),
    );
  }
}
