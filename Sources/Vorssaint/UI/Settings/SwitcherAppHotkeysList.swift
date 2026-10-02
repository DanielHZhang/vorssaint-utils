// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// The app window hotkeys block on the Switcher page: one row per app with
/// the shortcut that jumps to that app's windows in the switcher.
struct SwitcherAppHotkeysList: View {
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.isEnabled) private var isEnabled
    @State private var bindings: [SwitcherAppHotkey] = Self.savedBindings
    @State private var recordingBundleID: String?
    @State private var recordError: String?
    @State private var recordErrorBundleID: String?

    private var text: SwitcherAppHotkeyStrings {
        FeatureStrings.switcherAppHotkeys(l10n.language)
    }

    var body: some View {
        AppBundleList(title: text.listTitle,
                      caption: text.caption,
                      addTitle: text.addButton,
                      removeLabel: text.removeButton,
                      bundleIDs: bindings.map(\.bundleIdentifier),
                      reachesEveryApp: true,
                      onAdd: { bundleID in
                          save(SwitcherAppHotkeys.upserted(
                              bindings,
                              SwitcherAppHotkey(bundleIdentifier: bundleID, shortcut: nil)))
                      },
                      onRemove: { bundleID in
                          save(SwitcherAppHotkeys.removing(bundleIdentifier: bundleID,
                                                           from: bindings))
                      }) { bundleID in
            shortcutField(for: bundleID)
        }
        .onChange(of: l10n.language) { _, _ in
            recordError = nil
            recordErrorBundleID = nil
        }
    }

    private func shortcutField(for bundleID: String) -> some View {
        let binding = bindings.first { $0.bundleIdentifier == bundleID }
        let shortcut = binding?.parsedShortcut
        return VStack(alignment: .trailing, spacing: 4) {
            ShortcutRecorderButton(
                shortcut: shortcut ?? .switcherDefault,
                isEnabled: isEnabled,
                waitingTitle: l10n.s.shortcutPressKeys,
                emptyTitle: shortcut == nil ? text.noShortcut : nil,
                clearAction: {
                    save(SwitcherAppHotkeys.upserted(
                        bindings,
                        SwitcherAppHotkey(bundleIdentifier: bundleID, shortcut: nil)))
                },
                notCapturedAction: {
                    recordError = l10n.s.shortcutNotCaptured
                    recordErrorBundleID = bundleID
                },
                recordingChanged: { recording in
                    recordingBundleID = recording ? bundleID : nil
                    if recording {
                        recordError = nil
                        recordErrorBundleID = nil
                    }
                },
                invalidAction: {
                    recordError = l10n.s.shortcutInvalid
                    recordErrorBundleID = bundleID
                },
                captureAction: { captured in
                    capture(captured, for: bundleID)
                })
                .frame(width: 120)
            if let recordError, recordErrorBundleID == bundleID {
                Text(recordError)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            } else if recordingBundleID == bundleID {
                Text(ShortcutRecordingCaption.text(l10n.s, canClear: shortcut != nil))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func capture(_ captured: GlobalShortcut, for bundleID: String) {
        // A combination another feature already answers to would never reach
        // this app alone, so keep the row unset and say whose it is. The two
        // switcher shortcuts are checked even while the switcher is off: a
        // binding prepared now must not turn dead the moment it is enabled.
        if let conflict = GlobalShortcutRole.conflict(for: captured, excluding: nil) {
            recordError = String(format: l10n.s.shortcutConflictFormat, conflict.title(l10n.s))
            recordErrorBundleID = bundleID
            return
        }
        let switcherShortcut = GlobalShortcut.saved(for: DefaultsKey.switcherShortcut,
                                                    fallback: .switcherDefault)
        let windowShortcut = GlobalShortcut.saved(for: DefaultsKey.switcherWindowShortcut,
                                                  fallback: .switcherWindowDefault)
        if captured == switcherShortcut || captured == windowShortcut {
            recordError = String(format: l10n.s.shortcutConflictFormat, l10n.s.switcherSection)
            recordErrorBundleID = bundleID
            return
        }
        save(SwitcherAppHotkeys.upserted(
            bindings,
            SwitcherAppHotkey(bundleIdentifier: bundleID, shortcut: captured.storageValue)))
    }

    private static var savedBindings: [SwitcherAppHotkey] {
        SwitcherAppHotkeys.decode(
            UserDefaults.standard.data(forKey: DefaultsKey.switcherAppHotkeys))
    }

    private func save(_ updated: [SwitcherAppHotkey]) {
        if let data = SwitcherAppHotkeys.encode(updated) {
            UserDefaults.standard.set(data, forKey: DefaultsKey.switcherAppHotkeys)
        }
        bindings = Self.savedBindings
        AppSwitcher.shared.syncWithPreferences()
    }
}
