# pip3 install numpy
# pip3 install matplotlib

from matplotlib import pyplot as plt
import numpy as np
import math #needed for definition of pi
x = np.array([1, 2, 3, 4, 5])
y = np.array([3, 3, 1, 1, 2])
plt.plot(x,y)
plt.xticks([1, 3, 5], ["7.5", "RC", "R"])
plt.grid("on")
plt.xlabel("Horizontal")
plt.ylabel("Vertiacal")
plt.title('Python graph')
plt.show()
