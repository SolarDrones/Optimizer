#This is the main and assembly for the solar optimization problem

from openmdao.main.api import Assembly
from openmdao.lib.drivers.api import SLSQPdriver

#Optimization of a solar powered UAV
class SolarOptimization(Assembly):
    def configure(self):

        #Create driver instance
        self.add('driver', SLSQPdriver)

        #Create component instances
