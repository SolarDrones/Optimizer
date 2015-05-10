#This is the main and assembly for the solar optimization problem

from openmdao.main.api import Assembly
from openmdao.lib.drivers.api import SLSQPdriver

class SolarOptimization(Assembly):
    """This is the main assembly for the optimization of the solar UAV"""
    def configure(self):

        #Create driver instance
        self.add('driver', SLSQPdriver)

        #Create component instances and their constraints

        #Airfoil Geometry
        self.add('airfoil', Airfoil_Geometry())

        #Constrain the airfcraft to fly between 0 and 15 m/s
        self.driver.add_constraint('airfoil.u_inf > 0.0')
        self.driver.add_constraint('airfoil.u_inf < 15.0')

        #Constrain the angle of attack to be between -2 and 8 degrees
        self.driver.add_constraint('airfoil.alpha > -2.0')
        self.driver.add_constraint('airfoil.alpha < 8.0')
