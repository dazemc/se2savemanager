import 'package:hive_ce/hive_ce.dart';
import 'package:se2savemanager/models/managed_save.dart';

@GenerateAdapters([AdapterSpec<ManagedSave>()])
part 'hive_adapters.g.dart';
