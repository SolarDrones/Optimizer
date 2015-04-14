#This is the main and assembly for the solar optimization problem

from openmdao.main.api import Assembly 
from openmdao.lib.drivers.api import SLSQPdriver

#Optimization of a solar powered UAV
class SolarOptimization(Assembly):
    def configure(self):

        #create driver instance
        self.add('driver', SLSQPdriver)

        #create component instances
        