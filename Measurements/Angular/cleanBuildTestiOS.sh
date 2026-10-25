#!/bin/bash

# Ścieżka do natywnego folderu iOS w Twoim projekcie (zawierającego App.xcworkspace)
PROJECT_DIR="$HOME/Desktop/PracaMagisterska/Module1/Angular/gakko-mobile-module1/ios/App"
OUTPUT_FILE="$HOME/Desktop/ios_build_times.txt"

echo "--- Pomiary czasu budowania (iOS - Czysty/Zimny Start) ---" > "$OUTPUT_FILE"
TOTAL_TIME=0

cd "$PROJECT_DIR" || { echo "BŁĄD: Nie znaleziono folderu $PROJECT_DIR"; exit 1; }

for i in {1..10}; do
    echo -e "\033[36mRozpoczynam iterację $i z 10...\033[0m"

    # Głębokie czyszczenie cache'u i starych plików budowania Xcode
    echo "Czyszczenie pamięci podręcznej (DerivedData)..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/*
    xcodebuild clean -workspace App.xcworkspace -scheme App -quiet

    # Pomiar czasu w milisekundach (macOS używa do tego wbudowanego Perla)
    echo "Budowanie natywnej aplikacji..."
    START_TIME=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)')

    # Kompilacja z terminala z flagami wyłączającymi podpisywanie
    xcodebuild build -workspace App.xcworkspace -scheme App -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -quiet

    END_TIME=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)')
    DURATION=$((END_TIME - START_TIME))
    TOTAL_TIME=$((TOTAL_TIME + DURATION))

    LOG_LINE="Iteracja $i: $DURATION ms"
    echo -e "\033[32m$LOG_LINE\033[0m"
    echo "$LOG_LINE" >> "$OUTPUT_FILE"
done

AVERAGE=$((TOTAL_TIME / 10))
echo "-----------------------------------------" >> "$OUTPUT_FILE"
echo "Średni czas budowania: $AVERAGE ms" >> "$OUTPUT_FILE"

echo -e "\033[33mPomiary zakończone. Wyniki zapisane w $OUTPUT_FILE na Biurku.\033[0m"
