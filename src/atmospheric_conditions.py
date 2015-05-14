# Finds the atmospheric conditions for the operating conditions
# Uses the US Standard Atmosphere from 1976

from openmdao.main.api import Component
from openmdao.lib.datatypes.api import Enum, Float

class Atmospheric_Conditions(Component):
    """
    This is the OpenMDAO component that descirbes the atmospheric conditions

    Inputs
    ------
    altitude = altitude for flight (m)

    Outputs
    -------
    rho = density of the air (kg/m**3)
    """

    # Setup the framework
    # Inputs
    altitude = Float(10., iotype='in', units='m', desc='Flying operational altitude')

    # Outputs
    rho = Float(0., iotype='out', units='kg/m**3', desc='The density of air')

    def execute(self):
        self.rho = calculate_density(self.altitude)




def calculate_density(altitude):
    """
    Calculates the density for a given altitude using a regression form the
    US Standard Atmosphere

    Goodness of fit:
    SSE: 2.927e-06
    R-square: 1
    Adjusted R-square: 1
    RMSE: 0.0007651

    Arguments
    ---------
    altitude = altitude for flight (m)

    Returns
    -------
    rho = density of the air (kg/m**3)
    """

    return 4.003 * 10**-9 * altitude**2 - 0.0001178 * altitude + 1.226
