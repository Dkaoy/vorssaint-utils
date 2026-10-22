#!/bin/zsh
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Vorssaint
# Focused regression checks for the local translation and Hosts additions.
# No app install, keychain setup, real API calls or privileged hosts writes.
set -euo pipefail
cd "$(dirname "$0")/.."
SDK="${SDKROOT:-$(xcrun --show-sdk-path)}"
if [[ -z "${SDKROOT:-}" && -d /Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk ]]; then
    SDK=/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk
fi
OUTPUT=build/fork-tests
mkdir -p "$OUTPUT"
FLAGS=(-Onone -whole-module-optimization -target arm64-apple-macosx14.0 -sdk "$SDK" -module-cache-path "$OUTPUT/cache")
run_translation() {
    swiftc "${FLAGS[@]}" Sources/Vorssaint/Services/Translation/{TranslationSupport,AITranslation,CodexTranslation,BobPluginWorker}.swift \
        Tests/Fork/TranslationTests.swift -o "$OUTPUT/translation-tests"
    "$OUTPUT/translation-tests"
}
run_hosts() {
    swiftc "${FLAGS[@]}" Sources/Vorssaint/Services/Hosts/HostsSupport.swift Tests/Fork/HostsTests.swift -o "$OUTPUT/hosts-tests"
    "$OUTPUT/hosts-tests"
    swiftc "${FLAGS[@]}" Sources/Vorssaint/Services/Hosts/{HostsSupport,HostsService}.swift \
        Sources/Vorssaint/Services/PrivateFileStore.swift Sources/Vorssaint/Core/HostsStrings.swift \
        Tests/Fork/HostsServiceTests.swift -o "$OUTPUT/hosts-service-tests"
    "$OUTPUT/hosts-service-tests"
}
run_appearance() {
    swiftc "${FLAGS[@]}" Sources/Vorssaint/Core/NotchAppearanceSupport.swift Tests/Fork/NotchAppearanceTests.swift -o "$OUTPUT/notch-appearance-tests"
    "$OUTPUT/notch-appearance-tests"
}
case "${1:-all}" in
    translation) run_translation ;;
    hosts) run_hosts ;;
    appearance) run_appearance ;;
    all) run_translation; run_hosts; run_appearance ;;
    *) print -u2 'Usage: zsh Tools/test-fork-features.sh [all|translation|hosts|appearance]'; exit 2 ;;
esac
