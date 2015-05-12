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
    altitude = Float(0., iotype='in', units='m', desc='Flying operational altitude')

    # Outputs
    rho = Float(0., iotype='out', units='kg/m**3', desc='The density of air')

    def execute(self):
        altitude = self.altitude
        temperature = calculate_temperature(altitude)
        self.rho = calculate_density(altitude, temperature)




def get_pressure(altitude):
    """
    Calculates the pressure based on the altitude

    Arguments
    ---------
    altitude = altitude for flight

    Returns
    -------
    pressure = pressurefrom perscribed altitude (kPa)
    """

    # Computed using a quadratic regression from US Standard Atmosphere
    # R**2 = .9997
    return (6.312*10**-7 * altitude**2 * -0.01239 * altitude + 101.4) * 1000. # Last term is to convert to Pa




def calculate_temperature(altitude):
    """
    Calculates the air temperature for a given altitude

    Arguments
    ---------
    altitude = altitude for flight

    Returns
    -------
    temperature = temperature from perscribed altitude (K)
    """

    # Computed using a quadratic regression from US Standard Atmosphere
    # R**2 = .999912
    return ()-3.78571*10**-7 * altitude**2 - .00607405 * altitude + 14.9769) + 274.15 # Last term is to convert to K




def calculate_density(pressure, temperature):
    """
    Calculates the air density given an air pressure

    Arguments
    ---------
    altitude = altitude for flight

    Returns
    -------
    pressure = pressure from perscribed altitude (kPa)
    """

    # Uses the ideal gas law
    return p / (286.9 * temperature)
