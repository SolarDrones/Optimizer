from openmdao.main.api import Assembly
from paraboloid import Paraboloid

class connect_components(Assembly):
    """ Top level assembly """

    def configure(self):
        """ Creates a new assembly containing a chain of paraboloid components """

        self.add('par1', Paraboloid())
        self.add('par2', Paraboloid())
        self.add('par3', Paraboloid())

        self.driver.workflow.add(['par1', 'par2', 'par3'])

        self.connect('par1.f_xy', 'par2.x')
        self.connect('par2.f_xy', 'par3.y')

if __name__ == '__main__':
    a = connect_components()

    a.par1.x = 2.3
    a.par1.y = 7.2

    #a.par2.x is equal to par1.f_xy because of connection
    a.par2.y = 9.8

    a.par3.x = 1.5
    #a.par3.y is equal to par2.f_xy because of connection

    a.run()

    print "Parabolid 3 has output of %f" % a.par3.f_xy