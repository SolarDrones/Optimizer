from openmdao.main.api import Assembly,Component
from openmdao.lib.drivers.api import SLSQPdriver
from openmdao.lib.datatypes.api import Float

class Paraboloid_scale(Component):
    """ Evaluates the equation f(x,y) = (1000*x-3)^2 + (1000*x)*(0.01*y) + (0.01*y+4)^2 - 3 """

    # set up interface to the framework
    # pylint: disable-msg=E1101
    x = Float(0.0, iotype = 'in', desc = 'The variable x')
    y = Float(0.0, iotype = 'in', desc = 'The variable y')

    f_xy = Float(iotype = 'out', desc = 'f(x,y)')

    def execute(self):
        """
        f(x,y) = (x-3)^2 + xy + (y+4)^2 - 3
        Optimal solution (minimum): x = 0.0066666666666666671; y = -733.33333333333337
        """

        x = self.x
        y = self.y

        self.f_xy = (1000. * x - 3.) ** 2 + (1000. * x) * (0.01 * y) + (0.01 * y + 4.) ** 2 - 3.

class OptimizationUnconstrainedScale(Assembly):
    """Unconstrained optimization of the unscaled Paraboloid Component."""

    def configure(self):
        """ Creates a new Assembly containing an unscaled Paraboloid and an optimizer"""

        # Create Optimizer instance
        self.add('driver', SLSQPdriver())

        # Create Paraboloid component instances
        self.add('paraboloid', Paraboloid_scale())

        # Driver process definition
        self.driver.workflow.add('paraboloid')

        # SQLSQP Flags
        self.driver.iprint = 0

        # Objective
        self.driver.add_objective('paraboloid.f_xy')

        # Design Variables
        self.driver.add_parameter('paraboloid.x', low=-1000., high=1000., scaler=0.001)
        self.driver.add_parameter('paraboloid.y', low=-1000., high=1000., scaler=1000.0)

if __name__ == "__main__":
    opt_problem = OptimizationUnconstrainedScale()

    import time
    tt = time.time()

    opt_problem.run()

    print opt_problem.paraboloid.x,opt_problem.paraboloid.y
    print "Elapsed time: ", time.time()-tt, "seconds"
    print "Execution count: ", opt_problem.paraboloid.exec_count
