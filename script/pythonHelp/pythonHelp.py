# Helper functions for graphs.py

# Sorting version strings. Here are two examples of version strings:
# - 7.4-20190711.123301
# - 7.5-RC4
# - 7.4
#

import re
from operator import methodcaller

SNAPSHOT = 0
CANDIDATE = 1
RELEASE = 2

REGEX_SNAPSHOT = re.compile(r'(\d*)\.(\d*)-(\d{8})\.(\d{6})')
REGEX_CANDIDATE = re.compile(r'(\d*)\.(\d*)-RC(\d*)')
REGEX_RELEASE = re.compile(r'(\d*)\.(\d*)')

class SortableVersion:
    def __init__(self, versionString):
        self._versionString = versionString
        if REGEX_SNAPSHOT.match(versionString):
            self._kind = SNAPSHOT
            m = REGEX_SNAPSHOT.match(versionString)
            self._major = int(m.group(1))
            self._minor = int(m.group(2))
            self._dateStr = m.group(3)
            self._timeStr = m.group(4)
            self._rc = -1
        elif REGEX_CANDIDATE.match(versionString):
            self._kind = CANDIDATE
            m = REGEX_CANDIDATE.match(versionString)
            self._major = int(m.group(1))
            self._minor = int(m.group(2))
            self._rc = int(m.group(3))
            self._dateStr = ""
            self._timeStr = ""
        elif REGEX_RELEASE.match(versionString):
            self._kind = RELEASE
            m = REGEX_RELEASE.match(versionString)
            self._major = int(m.group(1))
            self._minor = int(m.group(2))
            self._rc = -1
            self._dateStr = ""
            self._timeStr = ""
        else:
            raise Exception("Unknown type of version string: {0}".format(versionString))

    def getVersionString(self):
        return self._versionString
    def getKind(self):
        return self._kind
    def getMajor(self):
        return self._major
    def getMinor(self):
        return self._minor
    def getRc(self):
        return self._rc
    def getDateStr(self):
        return self._dateStr
    def getTimeStr(self):
        return self._timeStr

def sortSortableVersions(l):
    return sorted(l, key=lambda s: (s.getMajor(), s.getMinor(), s.getKind(), s.getRc(), s.getDateStr(), s.getTimeStr()))

if __name__ == "__main__":
    from unittest import TestCase
    from unittest import main

    class SortableVersionTest(TestCase):
        def testSnapshot(self):
            instance = SortableVersion("11.24-20190711.123301")
            self.assertEqual(SNAPSHOT, instance.getKind())
            self.assertEqual(11, instance.getMajor())
            self.assertEqual(24, instance.getMinor())
            self.assertEqual("20190711", instance.getDateStr())
            self.assertEqual("123301", instance.getTimeStr())
        def testCandidate(self):
            instance = SortableVersion("71.53-RC112")
            self.assertEqual(CANDIDATE, instance.getKind())
            self.assertEqual(71, instance.getMajor())
            self.assertEqual(53, instance.getMinor())
            self.assertEqual(112, instance.getRc())
        def testRelease(self):
            instance = SortableVersion("12.14")
            self.assertEqual(RELEASE, instance.getKind())
            self.assertEqual(12, instance.getMajor())
            self.assertEqual(14, instance.getMinor())
        def testSorting(self):
            instances = [SortableVersion("7.5"), SortableVersion("7.5-20120711.133131"), SortableVersion("7.5-RC4"), SortableVersion("7.4")]
            sortedInstances = sortSortableVersions(instances)
            self.assertEqual(4, len(sortedInstances))
            self.assertEqual("7.4", sortedInstances[0].getVersionString())
            self.assertEqual("7.5-20120711.133131", sortedInstances[1].getVersionString())
            self.assertEqual("7.5-RC4", sortedInstances[2].getVersionString())
            self.assertEqual("7.5", sortedInstances[3].getVersionString())

    main()