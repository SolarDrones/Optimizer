#Finds a geometry for the airfoil using the source-vortex panel method
#Starts with a NACA5412

import math
import numpy
from scipy import integrate
from matplotlib import pyplot
from openmdao.main.api import Component
from openmdao.lib.datatypes.api import Array, Float

class airfoil_geom(Component):
    #Setup the framework
    #Inputs
    #X coordinates for the wing profile
    x = Array(array([1.0000000, .993046, .980661, .966053, .949774, .932497, .914705, .896663, .878492, .860248, .841955, .823625, .805263, .786873, .768873, .750020, .731561, .713085, .694592, .676086, .657568, .639042, .620509, .601972]))

    #Y coordinates for the wing profile

    #Output