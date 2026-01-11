import 'dart:convert';
import 'dart:io';

import 'save_utils.dart';

class ContainerBundles {
  final String systemRuntime;
  final String vRage;
  const ContainerBundles({required this.systemRuntime, required this.vRage});

  factory ContainerBundles.fromJson(Map<String, dynamic> json) {
    return ContainerBundles(
      systemRuntime: json['System.Runtime'] as String,
      vRage: json['VRage'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
    'System.Runtime': systemRuntime,
    'VRage': vRage,
  };
}

class ContainerInfo {
  final ContainerBundles bundles;
  final String type;
  final ContainerValue value;
  const ContainerInfo({
    required this.bundles,
    required this.type,
    required this.value,
  });

  factory ContainerInfo.fromDirectory(Directory dir) {
    final json = jsonDecode(getContainerInfo(dir).readAsStringSync());
    return ContainerInfo.fromJson(json);
  }

  factory ContainerInfo.fromJson(Map<String, dynamic> json) {
    return ContainerInfo(
      type: json[r'$Type'] as String,
      bundles: ContainerBundles.fromJson(json[r'$Bundles']),
      value: ContainerValue.fromJson(json[r'$Value']),
    );
  }

  Map<String, dynamic> toJson() => {
    r'$Bundles': bundles.toJson(),
    r'$Type': type,
    r'$Value': value.toJson(),
  };
}

class ContainerMeta {
  final String? baseMetadata;
  String displayName;
  final String description;
  final int gameVersion;
  final int gameBuildNumber;
  final int saveCreationTimeInTicks;
  final int pcu;
  final bool usedDebugMenu;
  ContainerMeta({
    this.baseMetadata,
    required this.displayName,
    required this.description,
    required this.gameVersion,
    required this.gameBuildNumber,
    required this.saveCreationTimeInTicks,
    required this.pcu,
    required this.usedDebugMenu,
  });

  factory ContainerMeta.fromJson(Map<String, dynamic> json) {
    return ContainerMeta(
      baseMetadata: json['BaseMetadata'] as String?,
      displayName: json['DisplayName'] as String,
      description: json['Description'] as String,
      gameVersion: json['GameVersion'] as int,
      gameBuildNumber: json['GameBuildNumber'] as int,
      saveCreationTimeInTicks: json['SaveGameCreationTimeInTicks'] as int,
      pcu: json['PCU'] as int,
      usedDebugMenu: json['UsedDebugMenu'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'BaseMetadata': baseMetadata,
    'DisplayName': displayName,
    'Description': description,
    "GameVersion": gameVersion,
    "GameBuildNumber": gameBuildNumber,
    "SaveGameCreationTimeInTicks": saveCreationTimeInTicks,
    "PCU": pcu,
    "UsedDebugMenu": usedDebugMenu,
  };
}

class ContainerValue {
  final ContainerMeta containerMeta;
  final Map additonalData;
  const ContainerValue({
    required this.containerMeta,
    required this.additonalData,
  });

  factory ContainerValue.fromJson(Map<String, dynamic> json) {
    return ContainerValue(
      additonalData: {}, // TODO: currently empty in my game
      containerMeta: ContainerMeta.fromJson(json['Meta']),
    );
  }
  Map<String, dynamic> toJson() => {
    'Meta': containerMeta.toJson(),
    'AdditionalData': additonalData,
  };
}
