# Finds a geometry for the entire aircraft

# Airfoil - Starts with a NACA5412
# Fueslage - Starts with a .5m x .5m square

import math
import numpy
from scipy import integrate
from airfoil_aeroynamics import *
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
    wing_volume = Useable space inside of the wing (m**3)
    quarter_chord_height = Distance between airfoil surfaces at the quarter chord (m)
    upper_surface_area = Surface area of the upper surface of the airfoil (m**2)
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

    rho = Float(0., iotype='in', units='kg/m**3', desc='The density of air')

    u_inf = Float(10., iotype='in', units='m/s', desc='The freestream velocity')
    alpha = Float(0., iotype='in', units='deg', desc='Angle of attack')

    wing_length = Float(1., iotype='in', units='m', desc='Length of the wing')
    wing_chord = Float(.1, iotype='in', units='m', desc='Chord of the wing')

    boom_diameter = Float(.05, iotype='in', units='m', desc='Diameter of the tail boom')
    boom_length = Float(.25, iotype='in', units='m', desc='Length of the tail boom')

    # Outputs
    cl = Float(0., iotype='out', desc='Coefficient of lift of the airfoil profile')
    lift = Float(0., iotype='out', units='N', desc='Lift of the aircraft')
    drag = Float(0., iotype='out', units='N', desc='Drag of the aircraft')
    wing_volume = Float(0., iotype='out', units='m**3', desc='Usesable space inside of the wing')
    quarter_chord_height = Float(0., iotype='out', units='m', desc='Height of the airfoil at quarter chord')
    upper_surface_area = Float(0., iotype='out', units='m**2', desc='Surface area of the top of the airfoil')

    def execute(self):
        self.cl = calculate_cl(self.x_foil, self.y_foil, self.u_inf, self.alpha)




def calculate_cl(x, y, u_inf, alpha):
    """
    Computes the cl of the airfoil section

    Arguments
    ---------
    x, y = The x and y coordinates of the airfoil profile
    u_inf = The freestream velocity
    alpha = the angle of attack of the airfoil
    """

    val_x, val_y = 0.1, 0.2
    x_min, x_max = x.min(), x.max()
    y_min, y_max = y.min(), y.max()
    x_start, x_end = x_min-val_x*(x_max-x_min), x_max+val_x*(x_max-x_min)
    y_start, y_end = y_min-val_y*(y_max-y_min), y_max+val_y*(y_max-y_min)

    # Apply panels to the geometry
    N = 50  # Number of panels
    panels = define_panels(x, y, N)  # Discretizes of the geometry into panels

    # Defines and creates the object freestream
    freestream = Freestream(u_inf, alpha)

    # Builds the panel matricies
    A = build_matrix(panels)           # calculates the singularity matrix
    b = build_rhs(panels, freestream)  # calculates the freestream RHS

    # solves the linear system
    variables = numpy.linalg.solve(A, b)

    for i, panel in enumerate(panels):
        panel.sigma = variables[i]
    gamma = variables[-1]

    # Computes the tangential velocity at each panel center.
    get_tangential_velocity(panels, freestream, gamma)

    # Computes surface pressure coefficient
    get_pressure_coefficient(panels, freestream)

    # Calculates the accuracy
    accuracy = sum([panel.sigma*panel.length for panel in panels])

    # Returns the coefficient of lift
    return gamma*sum(panel.length for panel in panels)/(0.5*freestream.u_inf*(x_max-x_min))
