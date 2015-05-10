#This is the main and assembly for the solar optimization problem

import time
import Airfoil_Geometry
from openmdao.main.api import Assembly
from openmdao.lib.drivers.api import CONMINdriver

class SolarOptimization(Assembly):
    """This is the main assembly for the optimization of the solar UAV"""
    def configure(self):

        #Create driver instance
        self.add('driver', CONMINdriver)

        #Create component instances and their constraints
        #Airfoil Geometry
        self.add('airfoil', Airfoil_Geometry())

        #Constrain the airfcraft to fly between 5 and 15 m/s
        self.driver.add_parameter('airfoil.u_inf', low=5., high=15.)

        #Constrain the angle of attack to be between -2 and 8 degrees
        self.driver.add_parameter('airfoil.alpha', low=-2., high=8.)




if __name__ == '__main__':
    """The main for the program to run"""

    #Define the problem
    opt_problem = SolarOptimization()

    #Time the solution
    tt = time.time()

    opt_problem.run()
