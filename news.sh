#!/bin/bash

# --- CONFIGURATION ---
# --- CONFIGURATION ---
HN_LIMIT=5
ARXIV_LIMIT=5

# --- MODEL SETUP (Configure Once) ---
CONFIG_FILE="$HOME/.tech_briefing_config"

if [ -f "$CONFIG_FILE" ]; then
    # Load the saved model if the config file exists
    source "$CONFIG_FILE"
else
    # Prompt the user if it's their first time running the script
    echo -e "\n👋 Welcome! Let's set up your local AI for the first time."
    read -p "Enter the Ollama model you want to use: " USER_MODEL
    
    # Use default if they just press Enter
    MODEL="${USER_MODEL:-minimax-m3:cloud}"
    
    # Save it to the config file for future runs
    echo "MODEL=\"$MODEL\"" > "$CONFIG_FILE"
    echo -e "✅ Saved '$MODEL' as your default model! (You can change this later by editing $CONFIG_FILE)\n"
    sleep 2
fi
# --- TERMINAL COLORS & STYLES ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[1;36m'
C_BLUE='\033[1;34m'
C_GREEN='\033[1;32m'
C_MAGENTA='\033[1;35m'
C_RED='\033[1;31m'

PRINT_LINE() { printf "${C_DIM}%*s${C_RESET}\n" "${COLUMNS:-80}" '' | tr ' ' '-'; }
PRINT_THICK_LINE() { printf "${C_MAGENTA}%*s${C_RESET}\n" "${COLUMNS:-80}" '' | tr ' ' '='; }

# --- SPINNER ANIMATION ---
trap 'stop_spinner; tput cnorm; echo -e "\n${C_RED}❌ Briefing aborted.${C_RESET}"; exit 1' INT

start_spinner() {
    local msg="$1"
    tput civis # Hide the cursor for a clean animation
    (
        local spin_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
        while true; do
            for i in $(seq 0 9); do
                printf "\r${C_CYAN}${spin_chars:$i:1}${C_RESET} ${C_DIM}%s${C_RESET}" "$msg"
                sleep 0.08
            done
        done
    ) &
    SPIN_PID=$!
}

stop_spinner() {
    if [ -n "$SPIN_PID" ]; then
        kill $SPIN_PID >/dev/null 2>&1
        wait $SPIN_PID 2>/dev/null
        printf "\r\033[K" # Clear the spinner line completely
        tput cnorm       # Restore the cursor
        SPIN_PID=""
    fi
}

# --- START SCRIPT ---
clear
PRINT_THICK_LINE
printf "${C_BOLD}${C_MAGENTA}%*s${C_RESET}\n" $(( (${COLUMNS:-80} + 32) / 2 )) "🚀 A.I. & TECH NEWS DASHBOARD 🚀"
PRINT_THICK_LINE
echo ""

# ==========================================
# 1. HACKER NEWS PROCESSING
# ==========================================
echo -e "${C_BOLD}${C_YELLOW}🔥 TOP $HN_LIMIT RECENT HACKER NEWS STORIES${C_RESET}\n"

start_spinner "Fetching latest stories from Hacker News..."
HN_IDS=$(curl -s --max-time 10 "https://hacker-news.firebaseio.com/v0/topstories.json" | jq -r ".[:$HN_LIMIT][]" 2>/dev/null)
stop_spinner
































if [ -z "$HN_IDS" ]; then
    echo -e "${C_RED}❌ Error: Could not retrieve stories from Hacker News API.${C_RESET}"
else
    for ID in $HN_IDS; do
        STORY_JSON=$(curl -s --max-time 5 "https://hacker-news.firebaseio.com/v0/item/${ID}.json")
        TITLE=$(echo "$STORY_JSON" | jq -r '.title // empty')
        URL=$(echo "$STORY_JSON" | jq -r '.url // "Text Submission"')
        SCORE=$(echo "$STORY_JSON" | jq -r '.score // 0')
        
        # Use jq's strftime to parse the Unix timestamp directly into a readable string
        PUB_DATE=$(echo "$STORY_JSON" | jq -r 'if .time then (.time | strftime("%b %d, %Y at %I:%M %p")) else "Unknown Time" end')
        
        if [ -z "$TITLE" ]; then
            continue
        fi

        echo -e "📌 Title:  ${C_BOLD}${C_YELLOW}$TITLE${C_RESET}"
        echo -e "🕒 Posted: ${C_CYAN}$PUB_DATE${C_RESET}"
        echo -e "🔗 Link:   ${C_BLUE}$URL${C_RESET} ${C_GREEN}($SCORE points)${C_RESET}"
        
        start_spinner "Generating AI summary..."
        
        PROMPT="Summarize this tech topic headline in 1 concise sentence: '$TITLE'"
        JSON_PAYLOAD=$(jq -n \
          --arg model "$MODEL" \
          --arg prompt "$PROMPT" \
          '{model: $model, prompt: $prompt, stream: false}')
        
        SUMMARY=$(curl -s -X POST http://localhost:11434/api/generate \
          -H "Content-Type: application/json" \
          -d "$JSON_PAYLOAD" | jq -r '.response')

        stop_spinner
        echo -e "🤖 ${C_DIM}Summary: $SUMMARY${C_RESET}\n"
    done
fi

PRINT_LINE

# ==========================================
# 2. ARXIV RESEARCH PROCESSING
# ==========================================
echo -e "${C_BOLD}${C_CYAN}🎓 TOP $ARXIV_LIMIT RECENT AI PAPERS FROM ARXIV${C_RESET}\n"

start_spinner "Querying arXiv database for the latest AI papers..."
ARXIV_URL="https://export.arxiv.org/api/query?search_query=cat:cs.AI&sortBy=lastUpdatedDate&sortOrder=descending&max_results=$ARXIV_LIMIT"
ATOM_XML=$(curl -s -L -A "CustomTechBriefing/1.0 (Local Bash Script)" --max-time 15 "$ARXIV_URL")
stop_spinner

if [ -z "$ATOM_XML" ] || ! echo "$ATOM_XML" | grep -q "<entry>"; then
    echo -e "${C_RED}❌ Error: Empty response or invalid XML layout from arXiv API.${C_RESET}"
else
    # Extracted the <updated> tag alongside the title and summary
    echo "$ATOM_XML" | awk '
        /<entry>/ { in_entry=1; id=""; title=""; summary=""; updated="" }
        /<\/entry>/ { 
            if(in_entry) {
                print "ID||"id; 
                gsub(/^[ \t]+|[ \t]+$/, "", title);
                print "TITLE||"title; 
                print "UPDATED||"updated;
                print "SUMMARY||"summary; 
                print "---END---"; 
                in_entry=0 
            }
        }
        in_entry && /<id>/ { 
            id = $0;
            gsub(/.*<id>/, "", id);
            gsub(/<\/id>.*/, "", id);
            next 
        }
        in_entry && /<title>/ { 
            title = $0;
            gsub(/.*<title>/, "", title);
            while (title !~ /<\/title>/ && getline) { title = title " " $0 }
            gsub(/<\/title>.*/, "", title);
            next 
        }
        in_entry && /<updated>/ { 
            updated = $0;
            gsub(/.*<updated>/, "", updated);
            gsub(/<\/updated>.*/, "", updated);
            next 
        }
        in_entry && /<summary>/ { 
            summary = $0;
            gsub(/.*<summary>/, "", summary); 
            while (summary !~ /<\/summary>/ && getline) { summary = summary " " $0 } 
            gsub(/<\/summary>.*/, "", summary);
            next 
        }
    ' > /tmp/arxiv_raw.txt

    TITLE="" ABSTRACT="" PDF_URL="" RAW_DATE=""
    
    while IFS= read -r line; do
        if [[ "$line" == ID\|\|* ]]; then
            PDF_URL="${line#ID||}"
        elif [[ "$line" == TITLE\|\|* ]]; then
            TITLE="${line#TITLE||}"
        elif [[ "$line" == UPDATED\|\|* ]]; then
            RAW_DATE="${line#UPDATED||}"
        elif [[ "$line" == SUMMARY\|\|* ]]; then
            ABSTRACT="${line#SUMMARY||}"
        elif [[ "$line" == "---END---" ]]; then
            if [ -n "$TITLE" ] && [ -n "$ABSTRACT" ]; then
                
                # Format arXiv XML Date (E.g. 2024-06-25T18:00:00Z -> 2024-06-25 at 18:00:00)
                FMT_DATE="${RAW_DATE/T/ at }"
                FMT_DATE="${FMT_DATE/Z/}"

                echo -e "📄 Paper:  ${C_BOLD}${C_CYAN}$TITLE${C_RESET}"
                echo -e "🕒 Updated: ${C_CYAN}$FMT_DATE${C_RESET}"
                
                ALPHAXIV_LINK=$(echo "$PDF_URL" | sed 's|http://arxiv.org|https://www.alphaxiv.org|' | sed 's|https://arxiv.org|https://www.alphaxiv.org|')
                echo -e "🔗 Link:   ${C_BLUE}${ALPHAXIV_LINK:-Unknown Link}${C_RESET}"
                
                start_spinner "Reading abstract and generating bullet points..."
                
                PROMPT="Summarize this abstract into two short bullet points:\n\nAbstract: $ABSTRACT"
                JSON_PAYLOAD=$(jq -n \
                  --arg model "$MODEL" \
                  --arg prompt "$PROMPT" \
                  '{model: $model, prompt: $prompt, stream: false}')
                
                SUMMARY=$(curl -s -X POST http://localhost:11434/api/generate \
                  -H "Content-Type: application/json" \
                  -d "$JSON_PAYLOAD" | jq -r '.response' | sed 's/^/  /')

                stop_spinner
                echo -e "${C_DIM}$SUMMARY${C_RESET}\n"
                
                TITLE="" ABSTRACT="" PDF_URL="" RAW_DATE=""
            fi
        fi
    done < /tmp/arxiv_raw.txt
    rm -f /tmp/arxiv_raw.txt
fi

PRINT_LINE
echo -e "${C_GREEN}✨ Briefing fully complete! Have a great day!${C_RESET}"
echo ""
