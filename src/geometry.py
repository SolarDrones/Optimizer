# Finds a geometry for the entire aircraft

# Airfoil - Starts with a NACA5412
# Fueslage - Starts with a .5m x .5m square

import math
import numpy
from scipy import integrate
from openmdao.main.api import Component
from openmdao.lib.datatypes.api import Array, Float

class Geometry(Component):
    """
    This is the OpenMDAO component that descirbes the geometry of the aircraft

    Inputs
    ------
    x_foil, y_foil = Coordinates of the airfoil
    x_fueslage, y_fuselage = Coordinates of the fueslage
    fueslage_length = length of the fueslage (m)
    rho = Density of the air (kg/m**3)
    u_inf = Freestream velocity (m/s)
    alpha = Angle of attack of the airfoil (deg)
    wing_length = wing length (m)
    wing_chord = wing chord length (m)
    boom_diameter = Diameter of the boom (m)
    boom_length = Length of the tail boom (m)

    Outputs
    -------
    cl = Coefficient of lift for the airfoil
    lift = Total lift of the aircraft (N)
    drag = Total drag of the aircraft (N)
    wing_volume = useable space inside of the wing (m**3)
    quarter_chord_height = Distance between airfoil surfaces at the quarter chord (m)
    upper_surface_area = Surface area of the upper surface of the airfoil
    """

    #Setup the framework
    #Inputs
    x_init, y_init = numpy.loadtxt('naca5412.dat', dtype = 'float', delimiter = ',', unpack = True)
    x_foil = Array(x_init, iotype='in', desc='The x coordinates of the airfoils')
    y_foil = Array(y_init, iotype='in', desc='The y coordinates of the airfoils')

    x_fueslage = Array([0., .1, .2, .3, .4, .5, .5, .5, .5, .5, .5, .4, .3, .2, .1, 0., 0., 0., 0., 0., 0.],
                       iotype='in', desc='The x coordinates of the fuselage')
    y_fuselage = Array([.5, .5, .5, .5, .5, .5, .4, .3, .2, .1, 0., 0., 0., 0., 0., 0., .1, .2, .3, .4, .5],
                       iotype='in', desc='The y coordinates of the fuselage')
    fueslage_length = Float(.5, iotype='in', units='m', desc= 'Length of th fuselage')

    rho = Float(0., iotype='out', units='kg/m**3', desc='The density of air')

    u_inf = Float(10., iotype='in', units='m/s', desc='The freestream velocity')
    alpha = Float(0., iotype='in', units='deg', desc='Angle of attack')

    wing_length = Float(1., iotype='in', units='m', desc='Length of the wing')
    wing_chord = Float(.1, iotype='in', units='m', desc='Chord of the wing')
