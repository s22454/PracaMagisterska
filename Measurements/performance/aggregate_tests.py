import os
import json
import pandas as pd

script_dir = os.path.dirname(os.path.abspath(__file__))
results_dir = os.path.join(script_dir, "measurements_json")

data_rows = []

if not os.path.exists(results_dir):
    print(f"Folder {results_dir} nie istnieje. Uruchom najpierw test.js.")
    exit(1)

# Sortowanie plików, aby zachować poprawną kolejność (session-1, session-2, ...)
filenames = sorted([f for f in os.listdir(results_dir) if f.endswith(".json")])

for i, filename in enumerate(filenames, start=1):
    filepath = os.path.join(results_dir, filename)
    with open(filepath, "r", encoding="utf-8") as f:
        try:
            content = json.load(f)
            agg = content.get("aggregated", {})

            row = {
                "Test": f"Test-{i}",  # Poprawione łączenie stringa z int oraz usunięty dwukropek z nazwy kolumny
                "Session_File": filename,
                "Memory_Max_MB": agg.get("memoryUsageMbMax", {}).get("value"),
                "Memory_Avg_MB": agg.get("memoryUsageMbAvg", {}).get("value"),
                "Total_Rss_Max_MB": agg.get("totalRssMbMax", {}).get("value"),
                "Total_Rss_Avg_MB": agg.get("totalRssMbAvg", {}).get("value"),
                "CPU_Max_%": agg.get("cpuMax", {}).get("value"),
                "CPU_Avg_%": agg.get("cpuAvg", {}).get("value"),
                "CPU_Usage_Max_%": agg.get("cpuUsagePercentageMax", {}).get("value"),
                "CPU_Usage_Avg_%": agg.get("cpuUsagePercentageAvg", {}).get("value"),
                "FPS_Max": agg.get("fpsMax", {}).get("value"),
                "FPS_Avg": agg.get("fpsAvg", {}).get("value"),
                "Slow_Frame_%": agg.get("slowFramePercent", {}).get("value"),
                "Network_Read_KB": agg.get("networkReadKbMax", {}).get("value"),
                "Network_Write_KB": agg.get("networkWriteKbMax", {}).get("value"),
                "Skin_Temp_Max_C": agg.get("temperatureCelsiusMax", {}).get("value"),
                "Skin_Temp_Avg_C": agg.get("temperatureCelsiusAvg", {}).get("value")
            }
            data_rows.append(row)
        except Exception as e:
            print(f"Błąd podczas parsowania pliku {filename}: {e}")

if not data_rows:
    print("Brak danych do przetworzenia.")
    exit(1)

df = pd.DataFrame(data_rows)

numeric_cols = df.select_dtypes(include=["number"]).columns
summary_stats = pd.DataFrame({
    "Minimum": df[numeric_cols].min(),
    "Maksimum": df[numeric_cols].max(),
    "Średnia": df[numeric_cols].mean(),
    "Odchylenie_Std": df[numeric_cols].std()
})

output_excel = os.path.join(script_dir, "aggregated_performance_results.xlsx")
with pd.ExcelWriter(output_excel, engine="openpyxl") as writer:
    df.to_excel(writer, sheet_name="Wszystkie Próby", index=False)
    summary_stats.to_excel(writer, sheet_name="Podsumowanie Statystyczne")

print(f"Pomyślnie wygenerowano zbiorczy raport: {output_excel}")
