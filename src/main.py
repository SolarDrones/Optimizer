# This is the main and assembly for the solar optimization problem

import time
from atmospheric_conditions import Atmospheric_Conditions
from geometry import Geometry
from openmdao.main.api import Assembly
from openmdao.lib.drivers.api import CONMINdriver

class SolarOptimization(Assembly):
    """This is the main assembly for the optimization of the solar UAV"""
    def configure(self):

        # Create CONMIN driver instance
        self.add('driver', CONMINdriver())
        self.driver.iprint = 0      # Surpress output
        self.driver.itmax = 30      # Max number of iterations

        # Create components and their parameters

        # Atmospheric Conditions
        self.add('conditions', Atmospheric_Conditions())

        # Constrain the operating altitude to be between 10 and 3000m
        self.driver.add_parameter('conditions.altitude', low=10., high=3000., scaler=.001)




        # Aircraft Geometry
        self.add('geometry', Geometry())

        # Constrain the y coordinates of the airfoil to be between -1 and 1
        self.driver.add_parameter('geometry.y_foil', low-1., high=1., scaler=1000.)

        # Constrain the x and y coordinates of the fuselage to be less than .5m
        self.driver.add_parameter('geometry.x_fueslage', low=0., high=.5, scaler=10.)
        self.driver.add_parameter('geometry.y_fueslage', low=0., high=.5, scaler=10.)

        # Constrain the fuselage length to be between 0 and 2 m
        self.driver.add_parameter('geometry.fuselage_length', low=0., high=2.)

        # Connect the density of the air to the ouptut of the atmospheric conditions
        self.connect('conditions.rho', 'geometry.rho')

        # Constrain the aircraft to fly between 5 and 15 m/s
        self.driver.add_parameter('geometry.u_inf', low=5., high=15.)

        # Constrain the angle of attack of the airfoil to be between -2 and 8 degrees
        self.driver.add_parameter('geometry.alpha', low=-2., high=8.)




        # Iteration Hierarchy
        self.driver.workflow.add(['conditions', 'geometry'])

        # Objective
        self.driver.add_objective('conditions.rho')




if __name__ == '__main__':
    """The main for the program to run"""

    # Define the problem
    opt_problem = SolarOptimization()

    # Time the and run solution
    tt = time.time()
    opt_problem.run()

    # Print the results
    print "\n"
    print "Solution: %f" % (opt_problem.conditions.rho)
    print "Elapsed time: ", time.time()-tt, "seconds"
