#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: Auto
# Auto-selected based on network analysis
# Defaults to general if no analysis available
# ═══════════════════════════════════════════════════════

# Check if there's a saved analysis result
ANALYSIS_FILE="${CONFIG_DIR}/network_analysis.json"

if [ -f "${ANALYSIS_FILE}" ]; then
    # Read recommended strategy from analysis
    RECOMMENDED=$(grep -o '"recommended_strategy":"[^"]*"' "${ANALYSIS_FILE}" 2>/dev/null | cut -d'"' -f4)

    if [ -n "${RECOMMENDED}" ] && [ -f "${INSTALL_DIR}/strategies/${RECOMMENDED}.sh" ]; then
        . "${INSTALL_DIR}/strategies/${RECOMMENDED}.sh"
        exit $?
    fi
fi

# Fallback to general
. "${INSTALL_DIR}/strategies/general.sh"
