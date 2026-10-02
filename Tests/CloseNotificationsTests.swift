// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

enum CloseNotificationsTests {
    /// Synthetic accessibility tree standing in for Notification Center:
    /// elements carry a role, children and actions, and the walk records
    /// every action it performs so the plan can be checked without a Mac.
    private final class Element {
        let role: String?
        var children: [Element]
        var actionList: [CloseNotificationAction]

        init(role: String?, children: [Element] = [], actions: [CloseNotificationAction] = []) {
            self.role = role
            self.children = children
            self.actionList = actions
        }
    }

    private final class Access: CloseNotificationAccess {
        typealias Element = CloseNotificationsTests.Element
        let windowList: [Element]
        private(set) var performed: [(action: String, element: Element)] = []
        var failingChildren = false

        init(windows: [Element]) { windowList = windows }

        func windows() throws -> [Element] { windowList }

        func children(_ element: Element) throws -> [Element] {
            struct Failure: Error {}
            if failingChildren { throw Failure() }
            return element.children
        }

        func role(_ element: Element) throws -> String? { element.role }

        func actions(_ element: Element) throws -> [CloseNotificationAction] { element.actionList }

        func perform(_ action: String, on element: Element) -> Bool {
            performed.append((action, element))
            return true
        }
    }

    private static func action(_ name: String, _ description: String? = nil) -> CloseNotificationAction {
        CloseNotificationAction(name: name, description: description)
    }

    private static let titles = CloseNotificationsSupport.Titles(clearAll: [], close: [])

    /// window → group → group → scroll area → two app sections, the exact
    /// hierarchy the Hammerspoon/JXA recipe walks. The first section holds
    /// two rows (one closable, one not) and a Close action of its own; the
    /// second offers Clear All.
    private static func centerTree() -> (access: Access, row: Element, firstSection: Element, secondSection: Element) {
        let row = Element(role: "AXGroup", actions: [action("AXClose", "Close")])
        let silentRow = Element(role: "AXGroup", actions: [action("AXPress", "Press")])
        let firstSection = Element(role: "AXGroup", children: [row, silentRow],
                                   actions: [action("AXClose", "Close")])
        let secondSection = Element(role: "AXGroup", actions: [action("AXClearAll", "Clear All")])
        let scrollArea = Element(role: "AXScrollArea", children: [firstSection, secondSection])
        let window = Element(role: "AXWindow", children: [
            Element(role: "AXGroup", children: [
                Element(role: "AXGroup", children: [scrollArea]),
            ]),
        ])
        return (Access(windows: [window]), row, firstSection, secondSection)
    }

    static func run(_ suite: TestSuite) {
        func expect(_ condition: Bool, _ message: String) {
            suite.expect(condition, message)
        }

        let tree = centerTree()
        let outcome = CloseNotificationsSupport.closeAll(access: tree.access, titles: titles)
        expect(outcome == .closed(3),
               "the walk closes the row, the first section and clears the second, got \(outcome)")
        expect(tree.access.performed.map(\.action) == ["AXClose", "AXClose", "AXClearAll"],
               "candidates run first-group rows, then the sections, in order")
        expect(tree.access.performed.first?.element === tree.row
               && tree.access.performed.last?.element === tree.secondSection,
               "actions land on the elements that offered them")

        // "Clear All" beats "Close" on the same element, as the JXA's
        // `closeAllAction ?? closeAction` reduced its list.
        let bothRow = Element(role: "AXGroup", actions: [action("AXClose", "Close"),
                                                         action("AXClearAll", "Clear All")])
        let bothSection = Element(role: "AXGroup", children: [bothRow])
        let bothAccess = Access(windows: [Element(role: "AXWindow", children: [
            Element(role: "AXScrollArea", children: [bothSection]),
        ])])
        expect(CloseNotificationsSupport.closeAll(access: bothAccess, titles: titles) == .closed(1)
               && bothAccess.performed.map(\.action) == ["AXClearAll"],
               "an element offering both actions is cleared all at once, not closed")

        // Action names that embed the title (the reader's "Name:" form)
        // match even when no description is readable.
        let namedRow = Element(role: "AXGroup", actions: [action("Name:Close\nTarget:0x0\nSelector:(null)")])
        let namedSection = Element(role: "AXGroup", children: [namedRow])
        let namedAccess = Access(windows: [Element(role: "AXWindow", children: [
            Element(role: "AXScrollArea", children: [namedSection]),
        ])])
        expect(CloseNotificationsSupport.closeAll(access: namedAccess, titles: titles) == .closed(1),
               "a Name:-prefixed action name matches its embedded title")

        // A localized title set matches the system's own words.
        let frenchRow = Element(role: "AXGroup", actions: [action("AXClose", "Fermer")])
        let frenchSection = Element(role: "AXGroup", children: [frenchRow])
        let frenchAccess = Access(windows: [Element(role: "AXWindow", children: [
            Element(role: "AXScrollArea", children: [frenchSection]),
        ])])
        let frenchTitles = CloseNotificationsSupport.Titles(clearAll: ["Tout effacer"], close: ["Fermer"])
        expect(CloseNotificationsSupport.closeAll(access: frenchAccess, titles: frenchTitles) == .closed(1),
               "localized action descriptions match the supplied titles")

        // Two actions with the same title cannot tell the walk which one
        // the system means, so that element is left alone.
        let ambiguousRow = Element(role: "AXGroup", actions: [action("AXCloseA", "Close"),
                                                              action("AXCloseB", "Close")])
        let ambiguousSection = Element(role: "AXGroup", children: [ambiguousRow])
        let ambiguousAccess = Access(windows: [Element(role: "AXWindow", children: [
            Element(role: "AXScrollArea", children: [ambiguousSection]),
        ])])
        expect(CloseNotificationsSupport.closeAll(access: ambiguousAccess, titles: titles) == .nothingToClose
               && ambiguousAccess.performed.isEmpty,
               "an ambiguous close action is never performed")

        // No window, and a window with no scrollable list, are both "the
        // center is not showing anything" rather than failures.
        expect(CloseNotificationsSupport.closeAll(access: Access(windows: []), titles: titles) == .noSurface,
               "no Notification Center window means no surface")
        let bareAccess = Access(windows: [Element(role: "AXWindow", children: [
            Element(role: "AXGroup"),
        ])])
        expect(CloseNotificationsSupport.closeAll(access: bareAccess, titles: titles) == .noSurface,
               "a window without a scroll area is not the notification list")

        // A list with nothing closable reports itself instead of pressing.
        let emptySection = Element(role: "AXGroup", children: [Element(role: "AXGroup")])
        let emptyAccess = Access(windows: [Element(role: "AXWindow", children: [
            Element(role: "AXScrollArea", children: [emptySection]),
        ])])
        expect(CloseNotificationsSupport.closeAll(access: emptyAccess, titles: titles) == .nothingToClose,
               "a list with no close actions closes nothing")

        // A failed read refuses the whole run: a partial tree never
        // authorizes pressing anything.
        let failing = centerTree()
        failing.access.failingChildren = true
        expect(CloseNotificationsSupport.closeAll(access: failing.access, titles: titles) == .unavailable
               && failing.access.performed.isEmpty,
               "a failed traversal performs no action at all")

        // Catalog and shortcut wiring.
        expect(AppFeature.closeNotifications.group == .tools
               && AppFeature.closeNotifications.symbolName == "bell.slash"
               && AppFeature.closeNotifications.permissions == [.accessibility]
               && AppFeature.closeNotifications.enabledKeys.isEmpty
               && !AppFeature.closeNotifications.installedByDefault,
               "close notifications is an opt-in Tools feature using Accessibility, on demand")
        expect(AppFeature.availabilityDefaults[AppFeature.closeNotifications.availabilityKey] as? Bool == false,
               "an update does not install close notifications on its own")
        let role = GlobalShortcutRole.closeNotifications
        expect(role.feature == .closeNotifications
               && role.storageKey == DefaultsKey.closeNotificationsShortcut
               && role.requiredEnableKeys == [DefaultsKey.closeNotificationsShortcutEnabled]
               && role.defaultShortcut == GlobalShortcut.closeNotificationsDefault
               && role.defaultShortcut.storageValue == "control+option+command:7",
               "the shortcut role ships control-option-command-X on its own defaults keys")
        expect(Defaults.registeredDefaults[DefaultsKey.closeNotificationsShortcut] as? String
               == GlobalShortcut.closeNotificationsDefault.storageValue
               && Defaults.registeredDefaults[DefaultsKey.closeNotificationsShortcutEnabled] as? Bool == false
               && Defaults.registeredDefaults[DefaultsKey.panelUtilityCloseNotifications] as? Bool == true,
               "the shortcut ships registered but off, and the panel tile starts visible")
        for language in AppLanguage.allCases {
            let strings = FeatureStrings.closeNotifications(language)
            expect(!strings.pageTitle.isEmpty && !strings.hubDescription.isEmpty
                   && !strings.panelCaption.isEmpty && !strings.clearButton.isEmpty
                   && !strings.hudCleared.isEmpty && !strings.hudNone.isEmpty,
                   "close notifications strings are complete in \(language.rawValue)")
        }
    }
}
