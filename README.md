# 🚀 A.I. & Tech News Briefing

> **A sleek terminal dashboard that curates and summarizes top Hacker News stories and the latest arXiv AI papers using local LLMs.**

Tired of context-switching between tabs to get your morning tech news? This lightweight Bash script brings the latest industry updates directly to your terminal. It fetches top stories from Hacker News, grabs the newest AI research from arXiv, and uses **your local AI (via Ollama)** to generate concise, readable summaries. No cloud API keys, no subscriptions, just pure local compute.

---

## ✨ Features

- **🤖 100% Local AI:** Uses [Ollama](https://ollama.com/) to process and summarize everything on your own machine. 
- **📰 Hacker News Curation:** Automatically fetches and summarizes the top trending tech stories.
- **🎓 arXiv to AlphaXiv:** Pulls the latest AI/ML research papers and intelligently links them to [AlphaXiv](https://www.alphaxiv.org/) so you can instantly see community discussions.
- **🎨 Sleek CLI Experience:** Features color-coded outputs, dynamic timestamps, and smooth Braille spinner animations.
- **⚙️ "Configure Once" Setup:** Prompts you for your preferred LLM on the first run and remembers it forever.

---

## 🛠️ Prerequisites

Before you start, ensure you have the following installed on your system:

1. **[Ollama](https://ollama.com/):** Must be installed and running in the background.
2. **`jq`:** A lightweight command-line JSON processor.
   - *Mac:* `brew install jq`
   - *Linux:* `sudo apt install jq`
3. **`curl` & `awk`:** (Usually pre-installed on almost all Mac/Linux systems).

---

## 🚀 Quick Start

**1. Download the script**
Save the script to your machine as `news.sh` (or clone the repository).

**2. Make it executable**
`chmod +x news.sh`

**3. Run the dashboard**
`./news.sh`

---

## ⚙️ Configuration 

### The Local LLM
On your very first run, the script will say hello and ask you which Ollama model you want to use (e.g., `llama3`, `mistral`, `minimax-m3:cloud`). 

It saves your choice to a hidden file at `~/.tech_briefing_config`. If you ever want to change your model, simply delete that file (`rm ~/.tech_briefing_config`) or edit it directly, and the script will ask you again next time!

### Tweak the Limits
Want more news? Less papers? Open `news.sh` in any text editor and change these variables at the very top of the file:
`HN_LIMIT=5`      # Number of Hacker News stories to fetch
`ARXIV_LIMIT=5`   # Number of arXiv papers to fetch

---

## 📸 What it Looks Like

================================================================================

                     🚀 A.I. & TECH NEWS DASHBOARD 🚀                    
                      
================================================================================

⚡ Checking AI Services...
⚡ Verifying model 'minimax-m3:cloud' is available...

--------------------------------------------------------------------------------
🔥 TOP 5 RECENT HACKER NEWS STORIES (Jul 17, 2026 at 08:30 AM)

📌 Title:  Show HN: I built a local AI briefing tool in Bash

🕒 Posted: Jul 17, 2026 at 07:15 AM

🔗 Link:   https://github.com/yourusername/repo (124 points)

🤖 Summary: A developer has created a sleek terminal script that uses Ollama to summarize Hacker News and arXiv papers entirely locally.

--------------------------------------------------------------------------------
🎓 TOP 5 RECENT AI PAPERS FROM ARXIV (Jul 17, 2026 at 08:30 AM)

📄 Paper:  Attention Is All You Need (Revisited)

🕒 Updated: 2026-07-16 at 18:00:00

🔗 Link:   https://www.alphaxiv.org/abs/xxxx.xxxxx

  - Researchers propose a new optimization for transformer architectures.
  - The model reduces computational overhead by 40% while maintaining accuracy.

--------------------------------------------------------------------------------
✨ Briefing fully complete! Have a great day!

---

## 🤝 Contributing
Found a bug? Have an idea for a cool new feature? Feel free to open an issue or submit a Pull Request! 

## 📜 License
This project is open-source and available under the [MIT License](LICENSE). 
