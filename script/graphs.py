# pip3 install numpy
# pip3 install matplotlib

from matplotlib import pyplot as plt
import numpy as np
import csv
from pythonHelp import pythonHelp

fileToProcess = "../work/output.csv"
adapter = "HandlePviewsDispatcher"
plottedField = "p50"

rows = []
with open(fileToProcess, newline="") as csvFile:
    reader = csv.DictReader(csvFile, dialect="excel", delimiter=";")
    for row in reader:
        rows.append(row)

rowsOfAdapter = [selectedRow for selectedRow in rows if selectedRow["adapter"].strip() == adapter.strip()]
rowsOfAdapter = sorted(rowsOfAdapter, key=lambda row: pythonHelp.sortableVersionKey(pythonHelp.SortableVersion(row["ibisversion"])))

def getLabel(previous, current):
    newVersion = (previous.getMinor() != current.getMinor()) or (previous.getMajor() != current.getMajor())
    newType = (previous.getKind() != current.getKind())
    if newVersion and (current.getKind() != pythonHelp.SNAPSHOT):
        return "N"
    if newVersion and (current.getKind() == pythonHelp.SNAPSHOT):
        return str(current.getMajor()) + "." + str(current.getMinor())
    if (not newVersion) and newType:
        if(current.getKind() == pythonHelp.CANDIDATE):
            return "C"
        if(current.getKind() == pythonHelp.RELEASE):
            return "R"
    return None

tickIdx = []
tickLabel = []
if(len(rowsOfAdapter) >= 2):
    for i in range(1, len(rowsOfAdapter)):
        label = getLabel(pythonHelp.SortableVersion(rowsOfAdapter[i-1]["ibisversion"]), pythonHelp.SortableVersion(rowsOfAdapter[i]["ibisversion"]))
        if label is not None:
            tickIdx.append(i)
            tickLabel.append(label)

x = np.arange(0, len(rowsOfAdapter))
y = np.array([row[plottedField] for row in rowsOfAdapter])
plt.plot(x,y)
plt.xlabel("version")
plt.ylabel(adapter + " - " + plottedField)
plt.title('Performance trend')
plt.xticks(tickIdx, tickLabel)
plt.grid("on")
plt.show()
