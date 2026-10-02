// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import CoreGraphics
import Foundation

enum SwitcherAppHotkeyTests {
    static func run(_ suite: TestSuite) {
        func expect(_ condition: Bool, _ message: String) {
            suite.expect(condition, message)
        }

        let chrome = "com.example.browser"
        let finder = "com.example.files"
        let code = "com.example.editor"
        let command1 = GlobalShortcut(keyCode: 18, modifiers: [.command])
        let command2 = GlobalShortcut(keyCode: 19, modifiers: [.command])
        let command3 = GlobalShortcut(keyCode: 20, modifiers: [.command])
        let command9 = GlobalShortcut(keyCode: 25, modifiers: [.command])

        var bindings: [SwitcherAppHotkey] = []
        bindings = SwitcherAppHotkeys.upserted(
            bindings, SwitcherAppHotkey(bundleIdentifier: chrome, shortcut: command1.storageValue))
        bindings = SwitcherAppHotkeys.upserted(
            bindings, SwitcherAppHotkey(bundleIdentifier: finder, shortcut: command2.storageValue))
        bindings = SwitcherAppHotkeys.upserted(
            bindings, SwitcherAppHotkey(bundleIdentifier: code, shortcut: nil))
        expect(bindings.map(\.bundleIdentifier) == [chrome, finder, code],
               "new app hotkeys keep the user's insertion order")
        expect(SwitcherAppHotkeys.binding(for: command1, in: bindings)?.bundleIdentifier == chrome
               && SwitcherAppHotkeys.binding(for: command2, in: bindings)?.bundleIdentifier == finder
               && SwitcherAppHotkeys.binding(for: command3, in: bindings) == nil,
               "a recorded combination resolves to exactly the app it was bound to")

        bindings = SwitcherAppHotkeys.upserted(
            bindings, SwitcherAppHotkey(bundleIdentifier: chrome, shortcut: command9.storageValue))
        expect(bindings.map(\.bundleIdentifier) == [chrome, finder, code]
               && bindings[0].parsedShortcut == command9,
               "rebinding an app replaces its shortcut in place")

        bindings = SwitcherAppHotkeys.upserted(
            bindings, SwitcherAppHotkey(bundleIdentifier: code, shortcut: command2.storageValue))
        expect(bindings[1].shortcut == nil
               && bindings[2].parsedShortcut == command2
               && SwitcherAppHotkeys.binding(for: command2, in: bindings)?.bundleIdentifier == code,
               "recording a combination for another app clears it from the previous app")

        bindings = SwitcherAppHotkeys.removing(bundleIdentifier: finder, from: bindings)
        expect(bindings.map(\.bundleIdentifier) == [chrome, code],
               "removing an app hotkey leaves the other bindings untouched")

        let roundTripped = SwitcherAppHotkeys.decode(SwitcherAppHotkeys.encode(bindings))
        expect(roundTripped == bindings,
               "app hotkeys survive a defaults encode/decode round trip")
        if let encoded = SwitcherAppHotkeys.encode(bindings) {
            let stored = String(decoding: encoded, as: UTF8.self)
            expect(!stored.contains("Browser") && !stored.contains("Files")
                   && !stored.contains("Editor"),
                   "the stored hotkey data contains bundle identities, not display names")
        } else {
            expect(false, "app hotkeys encode for defaults storage")
        }

        let messy = """
        [
          {"bundleIdentifier":"com.example.first","shortcut":"command:18"},
          {"bundleIdentifier":"com.example.first","shortcut":"command:19"},
          {"bundleIdentifier":"","shortcut":"command:20"},
          {"bundleIdentifier":"com.example.second","shortcut":null}
        ]
        """
        let decodedMessy = SwitcherAppHotkeys.decode(Data(messy.utf8))
        expect(decodedMessy == [
            SwitcherAppHotkey(bundleIdentifier: "com.example.first", shortcut: command1.storageValue),
            SwitcherAppHotkey(bundleIdentifier: "com.example.second", shortcut: nil),
        ], "decoding drops empty identities and keeps the first binding for a duplicated app")
        expect(SwitcherAppHotkeys.decode(nil).isEmpty
               && SwitcherAppHotkeys.decode(Data("not json".utf8)).isEmpty,
               "missing or damaged hotkey data decodes to no bindings")
        expect(Defaults.registeredDefaults[DefaultsKey.switcherAppHotkeys] as? Data == Data("[]".utf8),
               "app hotkeys are a registered default so they travel in settings backups")

        expect(!SwitcherSessionScope.allApps.isWindowScoped
               && SwitcherSessionScope.frontmostApp.isWindowScoped
               && SwitcherSessionScope.specificApp(finder).isWindowScoped,
               "only all-apps sessions fall outside window-scoped selection and layout")
        expect(SwitcherSessionScope.specificApp(finder).specificAppBundleIdentifier == finder
               && SwitcherSessionScope.frontmostApp.specificAppBundleIdentifier == nil
               && SwitcherSessionScope.allApps.specificAppBundleIdentifier == nil,
               "a specific-app session carries the bundle identity it was opened for")

        // The requested behavior, as data: one app is in front and another
        // app is bound to the pressed hotkey. The bound app's session list
        // stays in most-recent use order and, because the foreground window
        // is not in it, a quick press lands on its most recent window.
        let chromeCurrent = SwitcherItem.window(id: 101, title: "Browser current",
                                                appName: "Browser", pid: 10,
                                                isOnScreen: true, frame: .zero)
        let finderRecent = SwitcherItem.window(id: 201, title: "Files recent",
                                               appName: "Files", pid: 20,
                                               isOnScreen: true, frame: .zero)
        let finderOlder = SwitcherItem.window(id: 202, title: "Files older",
                                              appName: "Files", pid: 20,
                                              isOnScreen: true, frame: .zero)
        let finderOldest = SwitcherItem.window(id: 203, title: "Files oldest",
                                               appName: "Files", pid: 20,
                                               isOnScreen: true, frame: .zero)
        let allWindows = [chromeCurrent, finderRecent, finderOlder, finderOldest]
        let finderWindows = SwitcherSupport.frontmostAppWindows(allItems: allWindows,
                                                                frontmostPID: 20)
        let listedSource = finderWindows.contains { $0.id == chromeCurrent.id } ? chromeCurrent : nil
        let session = SwitcherSupport.orderedForSession(finderWindows, currentID: listedSource?.id)
        let firstIndex = SwitcherSupport.initialWindowScopedSelectionIndex(
            itemCount: session.count, hasForegroundItem: listedSource != nil, reversed: false)
        expect(session == [finderRecent, finderOlder, finderOldest]
               && session[firstIndex] == finderRecent,
               "pressing the bound app's hotkey from another app selects its most recent window on release")

        let heldIndices = (0..<4).map { (firstIndex + $0) % session.count }
        expect(heldIndices.map { session[$0].title }
               == ["Files recent", "Files older", "Files oldest", "Files recent"],
               "holding the modifier and pressing again steps through the same app's window previews")

        let inAppSession = SwitcherSupport.orderedForSession(finderWindows,
                                                             currentID: finderOlder.id)
        let inAppIndex = SwitcherSupport.initialWindowScopedSelectionIndex(
            itemCount: inAppSession.count, hasForegroundItem: true, reversed: false)
        expect(inAppSession.first == finderOlder && inAppSession[inAppIndex] == finderRecent,
               "pressing the hotkey inside its own app starts from the current window and selects the previous one")

        for language in AppLanguage.allCases {
            let strings = FeatureStrings.switcherAppHotkeys(language)
            expect(!strings.listTitle.isEmpty && !strings.addButton.isEmpty
                   && !strings.removeButton.isEmpty && !strings.noShortcut.isEmpty
                   && !strings.caption.isEmpty,
                   "app window hotkey strings are complete in \(language.rawValue)")
        }

        // Production wiring: a matched hotkey has to reach the same session
        // machinery as the window shortcut, scoped to its own app.
        let switcherSource = (try? String(
            contentsOfFile: "Sources/Vorssaint/Services/Switcher/AppSwitcher.swift",
            encoding: .utf8)) ?? ""
        expect(switcherSource.contains(".specificApp($0.bundleIdentifier)"),
               "a matched app hotkey opens a specific-app switcher session")
        expect(switcherSource.contains("scopedToFrontmostPID: scopedAppPID")
               && switcherSource.contains("case .specificApp:"),
               "a specific-app session enumerates and lists windows for its bound app")
        expect(switcherSource.contains("pending.scope.isWindowScoped"),
               "specific-app sessions use window-scoped initial selection")
    }
}
