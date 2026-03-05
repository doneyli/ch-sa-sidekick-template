# weekly-insights-format.jq
# Formats the aggregated JSON into a markdown summary.
# Input: the JSON report from weekly-insights-aggregate.jq
# Args: --arg from_display <str> --arg now_display <str>

"# Weekly Activity Data — \($from_display) to \($now_display)",
"",
"## Raw Numbers",
"",
"- **Sessions:** \(.summary.total_sessions)",
"- **Total turns:** \(.summary.total_turns)",
"- **Active days:** \(.summary.active_days)/\(.meta.days)",
"- **Avg turns/session:** \(.summary.avg_turns_per_session)",
"- **Busiest day:** \(.summary.busiest_day) (\(.summary.busiest_day_turns) turns)",
"",
"## Daily Activity",
"",
(.daily_activity | to_entries | sort_by(.key)[] |
    "- **\(.key)**: \(.value) turns \("#" * ([.value, 50] | min))"),
"",
"## Projects / Customers",
"",
(.projects | to_entries | sort_by(-.value)[] |
    "- **\(.key)**: \(.value) turns"),
"",
"## Skills Invoked",
"",
(if (.skills_invoked | length) > 0
    then (.skills_invoked | to_entries | sort_by(-.value)[] |
        "- `\(.key)`: \(.value)x")
    else "- No explicit skill invocations detected"
end),
"",
"## Top Tools Used",
"",
(.tools | to_entries | sort_by(-.value) | .[0:15][] |
    "- **\(.key)**: \(.value)x"),
"",
"## Session Log (most recent first)",
"",
"| When | Project | Turns | First Prompt |",
"|------|---------|-------|-------------|",
(.sessions | .[0:20][] |
    "| \(.last_seen[5:16] | gsub("T"; " ")) | \(.project) | \(.turns) | \(.first_input[0:80] | gsub("\\|"; "/") | gsub("\n"; " ")) |"),
"",
"## User Prompts (for topic analysis)",
"",
(.user_prompts | .[0:30][] |
    "- [\(.timestamp[5:16] | gsub("T"; " "))] **\(.project)**: \(.preview)")
