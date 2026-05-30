#!/bin/bash
# clipboard-relay.sh
# Écoute sur le port 8378 et envoie les données reçues dans pbcopy.
# Utilisé avec un reverse SSH tunnel depuis le serveur distant pour le copier-coller tmux.
# Fix: ignore les connexions vides pour ne pas écraser le clipboard Mac.

# pbcopy lit l'encodage via LANG/LC_CTYPE ; sans ça (launchd = env vide),
# il tombe sur MacRoman et transforme l'UTF-8 en mojibake (é -> √©).
export LANG=en_US.UTF-8
export LC_CTYPE=UTF-8

PORT=8378
TMPFILE=$(mktemp /tmp/clipboard-relay-buf.XXXXXX)
trap 'rm -f "$TMPFILE"' EXIT

while true; do
    nc -l localhost "$PORT" > "$TMPFILE" 2>/dev/null

    # Ne rien faire si les données reçues sont vides ou uniquement des espaces/newlines
    if [ -s "$TMPFILE" ] && grep -q '[^[:space:]]' "$TMPFILE"; then
        pbcopy < "$TMPFILE"
        echo "[$(date '+%H:%M:%S')] clipboard updated ($(wc -c < "$TMPFILE" | tr -d ' ') bytes)" >> /tmp/clipboard-relay.log
    else
        echo "[$(date '+%H:%M:%S')] ignored empty connection" >> /tmp/clipboard-relay.log
    fi
done
