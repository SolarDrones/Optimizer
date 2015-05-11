# This is the main and assembly for the solar optimization problem

import os
import time
from airfoil_geometry import Airfoil_Geometry
from openmdao.main.api import Assembly
from openmdao.lib.drivers.api import CONMINdriver
from openmdao.lib.casehandlers.api import JSONCaseRecorder

class SolarOptimization(Assembly):
    """This is the main assembly for the optimization of the solar UAV"""
    def configure(self):

        # Create CONMIN driver instance
        self.add('driver', CONMINdriver())
        self.driver.iprint = 0      # Surpress output
        self.driver.itmax = 30      # Max number of iterations

        # Create components and their parameters
        # Airfoil Geometry
        self.add('airfoil', Airfoil_Geometry())
        # Constrain the airfcraft to fly between 5 and 15 m/s
        self.driver.add_parameter('airfoil.u_inf', low = 5.0, high = 15.0)

        # Constrain the angle of attack to be between -2 and 8 degrees
        self.driver.add_parameter('airfoil.alpha', low=-2., high=8.)

        # Constrain the y coordinates of the airfoil to be between -1 and 1
        # Also add a 1000x scaler since the size is orders of magnitude smaller
        self.driver.add_parameter('airfoil.y', low=-1., high=1., scaler=1000.)

        # Iteration Hierarchy
        self.driver.workflow.add('airfoil')

        # Objective
        self.driver.add_objective('airfoil.cl')

        # Add in case recorder
        self.recorders = [JSONCaseRecorder('optimizer.json')]




if __name__ == '__main__':
    """The main for the program to run"""

    # Clear for the case recorders
    if os.path.exists('optimizer.json'):
        os.remove('optimizer.json')

    # Define the problem
    opt_problem = SolarOptimization()

    # Time the and run solution
    tt = time.time()
    opt_problem.run()

    # Print the results
    print "\n"
    print "Solution: %f" % (opt_problem.airfoil.cl)
    print "Elapsed time: ", time.time()-tt, "seconds"
