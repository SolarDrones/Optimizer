from openmdao.main.api import Component
from openmdao.lib.datatypes.api import Float 

class Paraboloid(Component):
    """ Evaluates the equation f(x,y) = (x-3)^2 + xy + (y+4)^2 - 3 """

    #Setup the framework
    #Inputs
    x = Float(0.0, iotype = 'in', desc = 'The variable x')
    y = Float(0.0, iotype = 'in', desc = 'The variable y')

    #Outputs
    f_xy = Float(0.0, iotype = 'out', desc = 'f(x,y)')

    def execute(self):
        """ f(x,y) = (x-3)^2 + xy + (y+4)^2 - 3 """

        x = self.x
        y = self.y

        self.f_xy = (x-3.0)**2 + x*y + (y+4.0)**2 - 3
