#!/bin/bash

# Zdefiniuj sciezki (dostosowane do struktury na MacinCloud)
MEASUREMENTS_DIR="$HOME/Desktop/PracaMagisterska/Measurements/Module1/Flutter/iOS"
PROJECT_DIR="$HOME/Desktop/PracaMagisterska/Projects/Module1/Flutter/gakko_mobile_module1"

# Upewnienie sie, ze folder na pomiary istnieje
mkdir -p "$MEASUREMENTS_DIR"

TIME_OUTPUT_FILE="$MEASUREMENTS_DIR/ios_build_times.txt"
DETAILED_LOG_FILE="$MEASUREMENTS_DIR/ios_build_details.log"

# Przygotowanie plikow wynikowych
echo "--- Pomiary czasu budowania (Flutter iOS Release) ---" > "$TIME_OUTPUT_FILE"
echo "--- Szczegolowe logi kompilacji Flutter/Xcode ---" > "$DETAILED_LOG_FILE"
TOTAL_TIME=0

# Przejscie do folderu projektu
cd "$PROJECT_DIR" || { echo "Blad: Nie znaleziono folderu $PROJECT_DIR"; exit 1; }

for i in {1..10}; do
    echo -e "\033[36mRozpoczynam iteracje $i z 10...\033[0m"

    # Znacznik nowej iteracji w pliku z logami
    echo -e "\n=========================================\nITERACJA $i\n=========================================" >> "$DETAILED_LOG_FILE"

    # Wymuszenie czystego budowania (Flutter clean usuwa cache oraz folder build)
    flutter clean > /dev/null 2>&1
    flutter pub get > /dev/null 2>&1

    # Rozpoczecie pomiaru czasu (w milisekundach, przy uzyciu wbudowanego w macOS Perla)
    START_TIME=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)')

    # Budowanie iOS (Runner.app) z pominięciem certyfikatów i generowanie statystyk rozmiaru
    # 2>&1 przechwytuje stdout i stderr, wrzucajac to do pliku logow
    flutter build ios --release --no-codesign --analyze-size >> "$DETAILED_LOG_FILE" 2>&1

    # Zakonczenie pomiaru czasu
    END_TIME=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)')
    DURATION=$((END_TIME - START_TIME))
    TOTAL_TIME=$((TOTAL_TIME + DURATION))

    # Zapis i wyswietlenie surowego czasu do osobnego pliku
    LOG_LINE="Iteracja $i: $DURATION ms"
    echo -e "\033[32m$LOG_LINE\033[0m"
    echo "$LOG_LINE" >> "$TIME_OUTPUT_FILE"

    # Skopiowanie wygenerowanego pliku ze statystykami rozmiaru
    STATS_FILE=$(find build -name "*size-analysis*.json" | head -n 1)
    if [ -n "$STATS_FILE" ]; then
        cp "$STATS_FILE" "$MEASUREMENTS_DIR/stats_ios_$i.json"
        rm -f "$STATS_FILE"
    fi

    # Automatyczne pakowanie wygenerowanego Runner.app do pliku .ipa
    if [ -d "build/ios/iphoneos/Runner.app" ]; then
        # Tworzymy folder strukturalny Payload i kopiujemy aplikacje
        rm -rf build/ios/iphoneos/Payload
        mkdir -p build/ios/iphoneos/Payload
        cp -r build/ios/iphoneos/Runner.app build/ios/iphoneos/Payload/

        # Wchodzimy do folderu i pakujemy (quiet zip)
        cd build/ios/iphoneos
        IPA_NAME="app-release_iteracja_$i.ipa"
        zip -qr "$IPA_NAME" Payload

        # Przenosimy gotowe IPA do folderu z pomiarami
        mv "$IPA_NAME" "$MEASUREMENTS_DIR/"

        # Wracamy do glownego folderu projektu (powrot wyciszony)
        cd - > /dev/null
    fi
done

# Podsumowanie
AVERAGE=$((TOTAL_TIME / 10))
echo "-----------------------------------------" >> "$TIME_OUTPUT_FILE"
echo "Sredni czas budowania: $AVERAGE ms" >> "$TIME_OUTPUT_FILE"

echo -e "\033[33mPomiary zakonczone. Gotowe pliki IPA, szczegolowe logi i czasy znajduja sie w:\n$MEASUREMENTS_DIR\033[0m"
