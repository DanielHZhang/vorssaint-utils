// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// How the panel's per-process breakdowns decide what becomes a row. The
/// default combines helper processes under the app responsible for them and
/// only shows meaningful activity. Listing processes individually is the
/// looser mode, modeled on Stats' per-process lists: every process on its
/// own, no activity cutoffs, and a wider row budget to show them in.
enum ProcessBreakdownPolicy {
    /// How many rows a breakdown may show when processes are listed
    /// individually; matches the usage cache's capacity.
    static let individualRowLimit = 60

    static func listsIndividually(defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: DefaultsKey.monitorIndividualProcesses)
    }

    static func effectiveLimit(requested: Int, individual: Bool) -> Int {
        individual ? max(requested, individualRowLimit) : requested
    }

    static func cpuThreshold(individual: Bool) -> Double { individual ? 0 : 0.01 }
    static func gpuThreshold(individual: Bool) -> Double { individual ? 0 : 0.05 }
    static func energyThreshold(individual: Bool) -> Double { individual ? 0 : 2 }

    /// Memory ranks `ps` candidates before the kernel footprint read, which
    /// is one syscall per candidate; the looser listing ranks every process
    /// the snapshot carries instead of stopping at the default window.
    static func memoryCandidateLimit(requested: Int, individual: Bool) -> Int {
        individual ? .max : max(requested * 10, 120)
    }
}
