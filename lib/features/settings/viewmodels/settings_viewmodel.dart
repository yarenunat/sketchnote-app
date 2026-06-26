import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PencilDoubleTapAction {
  switchToEraser,
  undo,
  showColorPicker,
  none,
}

class SettingsState {
  final bool isLeftHandedMode;
  final PencilDoubleTapAction doubleTapAction;

  const SettingsState({
    this.isLeftHandedMode = false,
    this.doubleTapAction = PencilDoubleTapAction.switchToEraser,
  });

  SettingsState copyWith({
    bool? isLeftHandedMode,
    PencilDoubleTapAction? doubleTapAction,
  }) {
    return SettingsState(
      isLeftHandedMode: isLeftHandedMode ?? this.isLeftHandedMode,
      doubleTapAction: doubleTapAction ?? this.doubleTapAction,
    );
  }
}

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // In a real app, this would load from SharedPreferences.
    return const SettingsState();
  }

  void toggleHandedness() {
    state = state.copyWith(isLeftHandedMode: !state.isLeftHandedMode);
  }

  void setDoubleTapAction(PencilDoubleTapAction action) {
    state = state.copyWith(doubleTapAction: action);
  }
}

final settingsViewModelProvider = NotifierProvider<SettingsViewModel, SettingsState>(() {
  return SettingsViewModel();
});
