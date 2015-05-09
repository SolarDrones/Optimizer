from openmdao.main.api import Assembly
from paraboloid import Paraboloid

class basic_model(Assembly):
    """ Basic OpenMDAO assembly """

    def configure(self):
        """ Creates an assembly """

        #Create paraboloid instance
        self.add('par', Paraboloid())

        #Add to driver workflow
        self.driver.workflow.add('par')

if __name__ == '__main__':
    a = basic_model()
    x = 2.3
    y = 7.2
    a.par.x = x
    a.par.y = y
    a.run()
    f = a.par.f_xy

    print "Paraboloid with x = %f and y = %f has value %f" % (x, y, f)