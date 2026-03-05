# weekly-insights-aggregate.jq
# Aggregates Langfuse trace + observation data into a weekly insights report.
# Input: --slurpfile traces <file> --slurpfile obs <file>
# Args:  --arg from <ISO> --arg to <ISO> --arg days <N> --arg generated <ISO>

# Helper: extract project name from tags or metadata
def get_project:
    ((.tags // []) | map(select(. != "claude-code")) | first)
    // (if (.metadata | type) == "object" then (.metadata.project // "unknown") else "unknown" end);

# Helper: safely extract input content as string
def get_input_text:
    if (.input | type) == "object" then (.input.content // "" | tostring)
    elif (.input | type) == "string" then .input
    else ""
    end;

# --- Aggregate traces ---
($traces | length) as $total_turns |

# Per-session grouping
($traces | group_by(.sessionId) | map({
    session_id: .[0].sessionId,
    project: (.[0] | get_project),
    turns: length,
    first_seen: (map(.timestamp) | sort | first),
    last_seen: (map(.timestamp) | sort | last),
    first_input: (sort_by(.timestamp) | first | get_input_text | .[0:200])
}) | sort_by(.last_seen) | reverse) as $sessions |

# Daily activity
($traces | group_by(.timestamp[0:10]) | map({
    date: .[0].timestamp[0:10],
    count: length
}) | sort_by(.date)) as $daily |

# Project counts
($traces | map(get_project) | group_by(.) | map({
    project: .[0],
    count: length
}) | sort_by(-.count)) as $projects |

# Skill invocations (prompts starting with /)
($traces | map(get_input_text) | map(select(test("^/"))) |
    map(capture("^/(?<skill>[a-zA-Z][\\w-]*)") | .skill) |
    group_by(.) | map({
        skill: ("/" + .[0]),
        count: length
    }) | sort_by(-.count)) as $skills |

# Tool usage from observations
($obs | map(.name // "") | map(select(startswith("Tool: "))) |
    map(ltrimstr("Tool: ")) |
    group_by(.) | map({
        tool: .[0],
        count: length
    }) | sort_by(-.count) | .[0:20]) as $tools |

# User prompts for topic analysis
($traces | sort_by(.timestamp) | reverse | .[0:50] | map({
    timestamp: .timestamp,
    session_id: .sessionId,
    project: get_project,
    preview: (get_input_text | .[0:150] | gsub("\n"; " "))
}) | map(select(.preview != ""))) as $prompts |

# Build final report
{
    meta: {
        generated: $generated,
        window_start: $from,
        window_end: $to,
        days: ($days | tonumber)
    },
    summary: {
        total_sessions: ($sessions | length),
        total_turns: $total_turns,
        active_days: ($daily | length),
        avg_turns_per_session: (if ($sessions | length) > 0
            then (($total_turns / ($sessions | length)) * 10 | round / 10)
            else 0 end),
        busiest_day: (if ($daily | length) > 0
            then ($daily | max_by(.count) | .date)
            else "" end),
        busiest_day_turns: (if ($daily | length) > 0
            then ($daily | max_by(.count) | .count)
            else 0 end)
    },
    daily_activity: ($daily | map({(.date): .count}) | add // {}),
    projects: ($projects | map({(.project): .count}) | add // {}),
    tools: ($tools | map({(.tool): .count}) | add // {}),
    skills_invoked: ($skills | map({(.skill): .count}) | add // {}),
    sessions: ($sessions | .[0:30]),
    user_prompts: $prompts
}
