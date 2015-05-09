from openmdao.main.api import Assembly
from openmdao.lib.drivers.api import SLSQPdriver
from paraboloid import Paraboloid 

class optimization_unconstrained(Assembly):
    """ Unconstrained optimization of the paraboloid component """

    def configure(self):

        #Create optimizer instance
        self.add('driver', SLSQPdriver())

        #Create paraboloid instance
        self.add('paraboloid', Paraboloid())

        #Iteration hierarchy
        self.driver.workflow.add('paraboloid')

        #SLSQP flags
        self.driver.iprint = 0

        #Objective function
        self.driver.add_objective('paraboloid.f_xy')

        #Design variables
        self.driver.add_parameter('paraboloid.x', low = -50.0, high = 50.0)
        self.driver.add_parameter('paraboloid.y', low = -50.0, high = 50.0)

if __name__ == '__main__':
    opt_problem = optimization_unconstrained()

    import time
    tt = time.time()

    opt_problem.run()

    print "\n"
    print "Minimum found at (%f, %f)" % (opt_problem.paraboloid.x, opt_problem.paraboloid.y)
    print "Elapsed time: ", time.time()-tt, "seconds"