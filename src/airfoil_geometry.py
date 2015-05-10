#Finds a geometry for the airfoil using the source-vortex panel method
#Starts with a NACA5412

import math
import numpy
from scipy import integrate
from matplotlib import pyplot
from openmdao.main.api import Component
from openmdao.lib.datatypes.api import Array, Float

class Airfoil_Geometry(Component):
    """
    This is the OpenMDAO component that descirbes the airfoil geometry
    Inputs: x and y coordinates of the airfoil
    Outputs:
    """

    #Setup the framework
    #Inputs
    x = Array(iotype='input', desc='The x coordinates of the airfoils')
    y = Array(iotype='input', desc='The y coordinates of the airfoils')

    """
    Output
    """

    def execute(self):
        x = self.x
        y = self.y




class Panel:
    """Contains information related to one panel."""
    def __init__(self, xa, ya, xb, yb):
        """
        Creates a panel.

        Arguments
        ---------
        xa, ya -- Cartesian coordinates of the first end-point.
        xb, yb -- Cartesian coordinates of the second end-point.
        """
        self.xa, self.ya = xa, ya
        self.xb, self.yb = xb, yb

        self.xc, self.yc = (xa+xb)/2, (ya+yb)/2            # control-point (center-point)
        self.length = math.sqrt((xb-xa)**2+(yb-ya)**2)     # length of the panel

        # orientation of the panel (angle between x-axis and panel's normal)
        if xb-xa <= 0.:
            self.beta = math.acos((yb-ya)/self.length)
        elif xb-xa > 0.:
            self.beta = math.pi + math.acos(-(yb-ya)/self.length)

        # location of the panel
        if self.beta <= math.pi:
            self.loc = 'extrados'
        else:
            self.loc = 'intrados'

        self.sigma = 0. # source strength
        self.vt = 0.    # tangential velocity
        self.cp = 0.    # pressure coefficient
