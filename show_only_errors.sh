#!/bin/bash
echo "=== Ambil hanya log error build terakhir ==="

# Ambil ID run terakhir
RUN_ID=$(gh run list --limit 1 --json databaseId -q '.[0].databaseId')
echo "📦 Workflow terakhir ID: $RUN_ID"

# Ambil log dan filter hanya error/fail/exception
gh run view $RUN_ID --log | grep -i -E "error|fail|exception"
