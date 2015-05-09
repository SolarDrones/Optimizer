from openmdao.main.api import Assembly
from openmdao.lib.drivers.api import SLSQPdriver
from paraboloid import Paraboloid 

class connected_optimization(Assembly):
    """Connected optimization of multiple paraboloids """

    def configure(self):
        #Create optimizer instance
        self.add('driver', SLSQPdriver())

        #Create paraboloid instances
        self.add('par1', Paraboloid())
        self.add('par2', Paraboloid())
        self.add('par3', Paraboloid())

        #Iteration hierarchy
        self.driver.workflow.add(['par1', 'par2', 'par3'])

        #Add connections
        self.connect('par1.f_xy', 'par2.x')
        self.connect('par2.f_xy', 'par3.y')

        #SLSQP flags
        self.driver.iprint = 0

        #Objective function
        self.driver.add_objective('par3.f_xy')

        #Design variables
        self.driver.add_parameter('par1.x', low = -50.0, high = 50.0)
        self.driver.add_parameter('par1.y', low = -50.0, high = 50.0)
        self.driver.add_parameter('par2.y', low = -50.0, high = 50.0)
        self.driver.add_parameter('par3.x', low = -50.0, high = 50.0)

if __name__ == '__main__':
    opt_problem = connected_optimization()

    import time
    tt = time.time()

    opt_problem.run()

    print '\n'
    print 'Minimum found at Par1: (%f, %f), Par2: (%f, %f), Par3: (%f, %f)' % (opt_problem.par1.x, opt_problem.par1.y, opt_problem.par2.x, opt_problem.par2.y, opt_problem.par3.x, opt_problem.par3.y)
    print 'Value: %f' % (opt_problem.par3.f_xy)
    print 'Elapsed time: ', time.time() - tt, 'seconds'