from openmdao.main.api import Assembly, Component
from openmdao.lib.drivers.api import DOEdriver
from openmdao.lib.doegenerators.api import Uniform

from openmdao.examples.simple.paraboloid import Paraboloid

from openmdao.lib.casehandlers.api import JSONCaseRecorder

class Analysis(Assembly):

    def configure(self):
        self.add('paraboloid', Paraboloid)

        self.add('driver', DOEdriver())
        self.driver.DOEgenerator = Uniform(1000)

        self.driver.add_parameter('paraboloid.x', low=-50, high=50)
        self.driver.add_parameter('paraboloid.y', low=-50, high=50)

        self.driver.add_response('paraboloid.f_xy')


if __name__ == "__main__":

    import time

    analysis = Analysis()

    tt = time.time()
    analysis.run()

    print "Elapsed time: ", time.time()-tt, "seconds"

    x = analysis.driver.case_inputs.paraboloid.x
    y = analysis.driver.case_inputs.paraboloid.y
    f_xy = analysis.driver.case_outputs.paraboloid.f_xy

    for i in range(0, len(x)):
        print "x: {} y: {} f(x, y): {}".format(x[i], y[i], f_xy[i])
