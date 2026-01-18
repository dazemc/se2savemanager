import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:se2savemanager/bloc/app/app_bloc.dart';
import 'package:se2savemanager/bloc/manager/manager_bloc.dart';
import 'package:se2savemanager/services/save_logger.dart';
import 'package:se2savemanager/widgets/save_content.dart';

class SaveAppContent extends StatelessWidget {
  const SaveAppContent({super.key});
  @override
  Widget build(BuildContext context) {
    final Logger log = SaveLogger(name: 'SaveAppContent').log;
    return BlocListener<ManagerBloc, ManagerState>(
      listenWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      listener: (context, state) {
        final appBloc = context.read<AppBloc>();
        final logManager = SaveLogger(name: 'MangerBloc').log;
        logManager.info(state);
        switch (state) {
          case ManagerInitial():
            {
              break;
            }
          case ManagerBusy():
            {
              appBloc.add(const AppManagerBusy());
              break;
            }
          case ManagerReady():
            {
              appBloc.add(const AppManagerReady());
              break;
            }
        }
      },
      child: BlocBuilder<AppBloc, AppState>(
        buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
        builder: (context, state) {
          log.info(state);
          return Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: .new(
                  image: AssetImage('assets/images/skybox.jpg'),
                  fit: .cover,
                ),
              ),
              child: SaveContent(state: state),
            ),
          );
        },
      ),
    );
  }
}
