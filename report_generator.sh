#!/bin/bash

# === Config ===
MODEL="llama3.2:latest"
INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.*}_report.md"
PDF_FILE="${INPUT_FILE%.*}_report.pdf"
TMP_PROMPT="/tmp/ai_report_prompt.txt"

if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 notes.md"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ Input file not found: $INPUT_FILE"
    exit 1
fi

# === Prompt ===
cat <<EOF > "$TMP_PROMPT"
You are a smart contract security expert writing a professional vulnerability report for a bug bounty program.

Based on the following structured notes, write a clear and concise report with these sections:
- Title
- Summary
- Affected Contract(s)
- Vulnerability Details
- Proof of Concept
- Impact
- Recommended Mitigation

Be formal, neutral, and precise. Do not include personal opinions or unnecessary verbosity.

Here are the notes:

$(cat "$INPUT_FILE")
EOF

# === Run the model ===
echo "⚙️ Generating report with $MODEL..."

ollama run "$MODEL" < "$TMP_PROMPT" > "$OUTPUT_FILE"

if [[ $? -ne 0 ]]; then
  echo "❌ Failed to generate report"
  exit 1
fi

echo "✅ Markdown report saved to: $OUTPUT_FILE"
