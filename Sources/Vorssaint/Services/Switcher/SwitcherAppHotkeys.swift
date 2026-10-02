// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// One entry of the app window hotkeys: a shortcut bound to one app, whose
/// windows the switcher then cycles on their own. The shortcut is a
/// `GlobalShortcut` storage value, nil until one is recorded.
struct SwitcherAppHotkey: Codable, Equatable, Identifiable {
    var bundleIdentifier: String
    var shortcut: String?

    var id: String { bundleIdentifier }

    /// The recorded shortcut, when the stored value still parses.
    var parsedShortcut: GlobalShortcut? {
        shortcut.flatMap { GlobalShortcut(storageValue: $0) }
    }
}

/// Reading, writing and reshaping the saved app window hotkeys. Pure, so
/// every rule here is pinned by tests.
enum SwitcherAppHotkeys {
    /// Enough apps for a person's dock habits, few enough that matching a
    /// key press against the list stays trivial.
    static let limit = 24

    static func decode(_ data: Data?) -> [SwitcherAppHotkey] {
        guard let data,
              let decoded = try? JSONDecoder().decode([SwitcherAppHotkey].self, from: data)
        else { return [] }
        var seen = Set<String>()
        return decoded.filter { binding in
            !binding.bundleIdentifier.isEmpty
                && seen.insert(binding.bundleIdentifier).inserted
        }
    }

    static func encode(_ bindings: [SwitcherAppHotkey]) -> Data? {
        try? JSONEncoder().encode(Array(bindings.prefix(limit)))
    }

    /// Inserts or replaces one binding. A combination belongs to one app at
    /// a time: recording it for another app clears it there, so a press can
    /// never be claimed by two apps at once.
    static func upserted(_ bindings: [SwitcherAppHotkey],
                         _ binding: SwitcherAppHotkey) -> [SwitcherAppHotkey] {
        var result = bindings.map { existing -> SwitcherAppHotkey in
            guard let shortcut = binding.shortcut,
                  existing.bundleIdentifier != binding.bundleIdentifier,
                  existing.shortcut == shortcut
            else { return existing }
            return SwitcherAppHotkey(bundleIdentifier: existing.bundleIdentifier, shortcut: nil)
        }
        if let index = result.firstIndex(where: { $0.bundleIdentifier == binding.bundleIdentifier }) {
            result[index] = binding
        } else {
            result.append(binding)
        }
        return Array(result.prefix(limit))
    }

    static func removing(bundleIdentifier: String,
                         from bindings: [SwitcherAppHotkey]) -> [SwitcherAppHotkey] {
        bindings.filter { $0.bundleIdentifier != bundleIdentifier }
    }

    /// The binding a recorded combination belongs to, if any. List order is
    /// the user's order, and the first match wins.
    static func binding(for shortcut: GlobalShortcut,
                        in bindings: [SwitcherAppHotkey]) -> SwitcherAppHotkey? {
        bindings.first { $0.parsedShortcut == shortcut }
    }
}
