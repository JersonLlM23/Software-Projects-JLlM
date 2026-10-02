import '/components/button/button_widget.dart';
import '/components/goal_card/goal_card_widget.dart';
import '/components/profile_stat/profile_stat_widget.dart';
import '/components/setting_row/setting_row_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'user_profile_widget.dart' show UserProfileWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class UserProfileModel extends FlutterFlowModel<UserProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ProfileStat.
  late ProfileStatModel profileStatModel1;
  // Model for ProfileStat.
  late ProfileStatModel profileStatModel2;
  // Model for ProfileStat.
  late ProfileStatModel profileStatModel3;
  // Model for GoalCard.
  late GoalCardModel goalCardModel1;
  // Model for GoalCard.
  late GoalCardModel goalCardModel2;
  // Model for SettingRow.
  late SettingRowModel settingRowModel1;
  // Model for SettingRow.
  late SettingRowModel settingRowModel2;
  // Model for SettingRow.
  late SettingRowModel settingRowModel3;
  // Model for SettingRow.
  late SettingRowModel settingRowModel4;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    profileStatModel1 = createModel(context, () => ProfileStatModel());
    profileStatModel2 = createModel(context, () => ProfileStatModel());
    profileStatModel3 = createModel(context, () => ProfileStatModel());
    goalCardModel1 = createModel(context, () => GoalCardModel());
    goalCardModel2 = createModel(context, () => GoalCardModel());
    settingRowModel1 = createModel(context, () => SettingRowModel());
    settingRowModel2 = createModel(context, () => SettingRowModel());
    settingRowModel3 = createModel(context, () => SettingRowModel());
    settingRowModel4 = createModel(context, () => SettingRowModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    profileStatModel1.dispose();
    profileStatModel2.dispose();
    profileStatModel3.dispose();
    goalCardModel1.dispose();
    goalCardModel2.dispose();
    settingRowModel1.dispose();
    settingRowModel2.dispose();
    settingRowModel3.dispose();
    settingRowModel4.dispose();
    buttonModel.dispose();
  }
}
