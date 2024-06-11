import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np

CSV_FILE_PATH = "hartje_processes.csv"

# Daten in einen DataFrame konvertieren
df = pd.read_csv(CSV_FILE_PATH, sep=";", header=None)

# Spalten umbenennen
df.columns = ["Zeitstempel", "Kategorie", "Wert"]

# Zeitstempel in ein Datetime-Objekt umwandeln
df["Zeitstempel"] = pd.to_datetime(df["Zeitstempel"], format="%Y-%m-%d %H:%M:%S")

# Diagramm erstellen
fig, ax = plt.subplots(figsize=(10, 6))

# Erstellen Sie eine Farbpalette mit so vielen eindeutigen Farben wie Kategorien
colors = plt.cm.viridis(np.linspace(0, 1, len(df["Kategorie"].unique())))

for color, category in zip(colors, df["Kategorie"].unique()):
    ax.plot(
        df[df["Kategorie"] == category]["Zeitstempel"],
        df[df["Kategorie"] == category]["Wert"],
        label=category,
        color=color,
    )

# Y-Achsen-Beschriftungen anpassen
formatter = ticker.FuncFormatter(lambda x, pos: "{:,.0f}".format(x))
ax.yaxis.set_major_formatter(formatter)

ax.set_xlabel("Timestamp")
ax.set_ylabel("RSS in kB")
ax.legend()
plt.show()
