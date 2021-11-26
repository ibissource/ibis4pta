# This script produces graphs from the output file of
# the ibis4pta Frank config. See the global variables at
# the top of this script for settings.
#
# This is a Python script that works with Python 3. Please
# install the following before running:
#
# pip3 install numpy
# pip3 install matplotlib

from matplotlib import pyplot as plt
import numpy as np
import csv
from pythonHelp import pythonHelp

fileToProcess = "../work/output.csv"
# adapter = "HandlePviewsDispatcher"
# adapter = "HandlePViewsGetData"
# adapter = "HandlePViewsOrchestrate"
# adapter = "HandlePviewsStore"
adapter = "TestXSLTPipe"

plottedFields = ["min", "max", "first", "last", "p50", "stdDev"]

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
yraw = []
for f in plottedFields:
    yraw.append([float(row[f]) for row in rowsOfAdapter])
ymax = max(max(yraw))
for currentY in yraw:
    y = np.array(currentY)
    plt.plot(x,y)
plt.legend(plottedFields)
plt.ylim(0, ymax)
plt.xlabel("version")
plt.ylabel(adapter)
plt.title('Performance trend')
plt.xticks(tickIdx, tickLabel)
plt.grid("on")
plt.show()
