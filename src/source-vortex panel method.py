#Uses the source vortex panel method to find the lift on a 2d airfoil section

import math
import numpy
from scipy import integrate
from matplotlib import pyplot


class Panel:
    """Contains information related to one panel."""
    def __init__(self, xa, ya, xb, yb):
        """Creates a panel.
        
        Arguments
        ---------
        xa, ya -- Cartesian coordinates of the first end-point.
        xb, yb -- Cartesian coordinates of the second end-point.
        """
        self.xa, self.ya = xa, ya
        self.xb, self.yb = xb, yb
        
        self.xc, self.yc = (xa+xb)/2, (ya+yb)/2       # control-point (center-point)
        self.length = math.sqrt((xb-xa)**2+(yb-ya)**2)     # length of the panel
        
        # orientation of the panel (angle between x-axis and panel's normal)
        if xb-xa <= 0.:
            self.beta = math.acos((yb-ya)/self.length)
        elif xb-xa > 0.:
            self.beta = math.pi + math.acos(-(yb-ya)/self.length)
        
        # location of the panel
        if self.beta <= math.pi:
            self.loc = 'extrados'
        else:
            self.loc = 'intrados'
        
        self.sigma = 0.                             # source strength
        self.vt = 0.                                # tangential velocity
        self.cp = 0.                                # pressure coefficient




class Freestream:
    """Freestream conditions."""
    def __init__(self, u_inf=1.0, alpha=0.0):
        """Sets the freestream conditions.
        
        Arguments
        ---------
        u_inf -- Farfield speed (default 1.0).
        alpha -- Angle of attack in degrees (default 0.0).
        """
        self.u_inf = u_inf
        self.alpha = alpha*math.pi/180          # degrees --> radians




def define_panels(x, y, N=40):
    """Discretizes the geometry into panels using 'cosine' method.
    
    Arguments
    ---------
    x, y -- Cartesian coordinates of the geometry (1D arrays).
    N - number of panels (default 40).
    
    Returns
    -------
    panels -- Numpy array of panels.
    """
    R = (x.max()-x.min())/2                                    # radius of the circle
    x_center = (x.max()+x.min())/2                             # x-coord of the center
    x_circle = x_center + R*numpy.cos(numpy.linspace(0, 2*math.pi, N+1))  # x-coord of the circle points
    
    x_ends = numpy.copy(x_circle)      # projection of the x-coord on the surface
    y_ends = numpy.empty_like(x_ends)  # initialization of the y-coord Numpy array

    x, y = numpy.append(x, x[0]), numpy.append(y, y[0])    # extend arrays using numpy.append
    
    # computes the y-coordinate of end-points
    I = 0
    for i in xrange(N):
        while I < len(x)-1:
            if (x[I] <= x_ends[i] <= x[I+1]) or (x[I+1] <= x_ends[i] <= x[I]):
                break
            else:
                I += 1
        a = (y[I+1]-y[I])/(x[I+1]-x[I])
        b = y[I+1] - a*x[I+1]
        y_ends[i] = a*x_ends[i] + b
    y_ends[N] = y_ends[0]
    
    panels = numpy.empty(N, dtype=object)
    for i in xrange(N):
        panels[i] = Panel(x_ends[i], y_ends[i], x_ends[i+1], y_ends[i+1])
    
    return panels



def integral(x, y, panel, dxdz, dydz):
    """Evaluates the contribution of a panel at one point.
    
    Arguments
    ---------
    x, y -- Cartesian coordinates of the point.
    panel -- panel which contribution is evaluated.
    dxdz -- derivative of x in the z-direction.
    dydz -- derivative of y in the z-direction.
    
    Returns
    -------
    Integral over the panel of the influence at one point.
    """
    def func(s):
        return ( ((x - (panel.xa - math.sin(panel.beta)*s))*dxdz 
                  + (y - (panel.ya + math.cos(panel.beta)*s))*dydz)
                / ((x - (panel.xa - math.sin(panel.beta)*s))**2 
                   + (y - (panel.ya + math.cos(panel.beta)*s))**2) )
    return integrate.quad(lambda s:func(s), 0., panel.length)[0]




def source_matrix(panels):
    """Builds the source matrix.
    
    Arguments
    ---------
    panels -- array of panels.
    
    Returns
    -------
    A -- NxN matrix (N is the number of panels).
    """
    A = numpy.empty((panels.size, panels.size), dtype=float)
    numpy.fill_diagonal(A, 0.5)
    
    for i, p_i in enumerate(panels):
        for j, p_j in enumerate(panels):
            if i != j:
                A[i,j] = 0.5/math.pi*integral(p_i.xc, p_i.yc, 
                                              p_j, 
                                              math.cos(p_i.beta), math.sin(p_i.beta))
    
    return A




def vortex_array(panels):
    """Builds the vortex array.
    
    Arguments
    ---------
    panels - array of panels.
    
    Returns
    -------
    a -- 1D array (Nx1, N is the number of panels).
    """
    a = numpy.zeros(panels.size, dtype=float)
    
    for i, p_i in enumerate(panels):
        for j, p_j in enumerate(panels):
            if i != j:
                a[i] -= 0.5/math.pi*integral(p_i.xc, p_i.yc, 
                                             p_j, 
                                             math.sin(p_i.beta), -math.cos(p_i.beta))
    return a




def kutta_array(panels):
    """Builds the Kutta-condition array.
    
    Arguments
    ---------
    panels -- array of panels.
    
    Returns
    -------
    a -- 1D array (Nx1, N is the number of panels).
    """
    N = panels.size
    a = numpy.zeros(N+1, dtype=float)
    # contribution from the source sheet of the first panel on the last one
    a[0] = 0.5/math.pi*integral(panels[N-1].xc, panels[N-1].yc, panels[0], 
                           -math.sin(panels[N-1].beta), +math.cos(panels[N-1].beta))
    # contribution from the source sheet of the last panel on the first one
    a[N-1] = 0.5/math.pi*integral(panels[0].xc, panels[0].yc, panels[N-1], 
                             -math.sin(panels[0].beta), +math.cos(panels[0].beta))
    # contribution from the vortex sheet of the first panel on the last one
    a[N] -= 0.5/math.pi*integral(panels[-1].xc, panels[-1].yc, panels[0], 
                               +math.cos(panels[-1].beta), math.sin(panels[-1].beta))
    # contribution from the vortex sheet of the last panel on the first one
    a[N] -= 0.5/math.pi*integral(panels[0].xc, panels[0].yc, panels[-1], 
                               +math.cos(panels[0].beta), math.sin(panels[0].beta))
    # contribution from the vortex sheet of the first panel on itself
    a[N] -= 0.5
    # contribution from the vortex sheet of the last panel on itself
    a[N] -= 0.5
 
    # contribution from the other panels on the first and last ones
    for i, panel in enumerate(panels[1:-1]):
        # contribution from the source sheet
        a[i+1] = 0.5/math.pi*(integral(panels[0].xc, panels[0].yc, panel, 
                               -math.sin(panels[0].beta), +math.cos(panels[0].beta))
                     + integral(panels[N-1].xc, panels[N-1].yc, panel, 
                               -math.sin(panels[N-1].beta), +math.cos(panels[N-1].beta)) )

        # contribution from the vortex sheet
        a[N] -= 0.5/math.pi*(integral(panels[0].xc, panels[0].yc, panel, 
                               +math.cos(panels[0].beta), math.sin(panels[0].beta))
                             + integral(panels[-1].xc, panels[-1].yc, panel, 
                               +math.cos(panels[-1].beta), math.sin(panels[-1].beta)) )
        
    return a




def build_matrix(panels):
    """Builds the matrix of the linear system.
    
    Arguments
    ---------
    panels -- array of panels.
    
    Returns
    -------
    A -- (N+1)x(N+1) matrix (N is the number of panels).
    """
    N = len(panels)
    A = numpy.empty((N+1, N+1), dtype=float)
    
    AS = source_matrix(panels)
    av = vortex_array(panels)
    ak = kutta_array(panels)
    
    A[0:N,0:N], A[0:N,N], A[N,:] = AS[:,:], av[:], ak[:]
    
    return A




def build_rhs(panels, freestream):
    """Builds the RHS of the linear system.
    
    Arguments
    ---------
    panels -- array of panels.
    freestream -- farfield conditions.
    
    Returns
    -------
    b -- 1D array ((N+1)x1, N is the number of panels).
    """
    N = len(panels)
    b = numpy.empty(N+1,dtype=float)
    
    for i, panel in enumerate(panels):
        b[i] = - freestream.u_inf * math.cos(freestream.alpha - panel.beta)
    b[N] = -freestream.u_inf*( math.sin(freestream.alpha-panels[0].beta)
                              +math.sin(freestream.alpha-panels[N-1].beta) )
    
    return b




def get_tangential_velocity(panels, freestream, gamma):
    """Computes the tangential velocity on the surface.
    
    Arguments
    ---------
    panels -- array of panels.
    freestream -- farfield conditions.
    gamma -- circulation density.
    """
    N = len(panels)
    A = numpy.empty((N, N+1), dtype=float)
    numpy.fill_diagonal(A, 0.0)
    
    for i, p_i in enumerate(panels):
        # contribution from vortex on itself
        A[i, N] = -0.5
        for j, p_j in enumerate(panels):
            if i != j:
                # contribution from the sources
                A[i,j] = 0.5/math.pi*integral(p_i.xc, p_i.yc, 
                                              p_j, 
                                              -math.sin(p_i.beta), math.cos(p_i.beta))
                # contribution the vortices
                A[i,N] -= 0.5/math.pi*integral(p_i.xc, p_i.yc, 
                                               p_j, 
                                               math.cos(p_i.beta), math.sin(p_i.beta))

    b = freestream.u_inf * numpy.sin([freestream.alpha - panel.beta for panel in panels])
    
    var = numpy.append([panel.sigma for panel in panels], gamma)
    
    vt = numpy.dot(A, var) + b
    for i, panel in enumerate(panels):
        panel.vt = vt[i]





def get_pressure_coefficient(panels, freestream):
    """Computes the surface pressure coefficients.
    
    Arguments
    ---------
    panels -- array of panels.
    freestream -- farfield conditions.
    """
    for panel in panels:
        panel.cp = 1.0 - (panel.vt/freestream.u_inf)**2




#Read the geometry from a data file
with open('naca5412.dat') as file_name:
    x, y = numpy.loadtxt(file_name, dtype = 'float', delimiter = ',', unpack = True)

#Plot the geometry
val_x, val_y = 0.1, 0.2
x_min, x_max = x.min(), x.max()
y_min, y_max = y.min(), y.max()
x_start, x_end = x_min-val_x*(x_max-x_min), x_max+val_x*(x_max-x_min)
y_start, y_end = y_min-val_y*(y_max-y_min), y_max+val_y*(y_max-y_min)

size = 10
pyplot.figure(figsize=(size, (y_end-y_start)/(x_end-x_start)*size))
pyplot.grid(True)
pyplot.xlabel('x', fontsize=16)
pyplot.ylabel('y', fontsize=16)
pyplot.xlim(x_start, x_end)
pyplot.ylim(y_start, y_end)
pyplot.plot(x, y, color='k', linestyle='-', linewidth=2)
pyplot.show()

#Now apply the panels to the geometry
N = 40                           # number of panels
panels = define_panels(x, y, N)  # discretizes of the geometry into panels

# plots the geometry and the panels
val_x, val_y = 0.1, 0.2
x_min, x_max = min( panel.xa for panel in panels ), max( panel.xa for panel in panels )
y_min, y_max = min( panel.ya for panel in panels ), max( panel.ya for panel in panels )
x_start, x_end = x_min-val_x*(x_max-x_min), x_max+val_x*(x_max-x_min)
y_start, y_end = y_min-val_y*(y_max-y_min), y_max+val_y*(y_max-y_min)

size = 10
pyplot.figure(figsize=(size, (y_end-y_start)/(x_end-x_start)*size))
pyplot.grid(True)
pyplot.xlabel('x', fontsize=16)
pyplot.ylabel('y', fontsize=16)
pyplot.xlim(x_start, x_end)
pyplot.ylim(y_start, y_end)
pyplot.plot(x, y, color='k', linestyle='-', linewidth=2)
pyplot.plot(numpy.append([panel.xa for panel in panels], panels[0].xa), 
            numpy.append([panel.ya for panel in panels], panels[0].ya), 
            linestyle='-', linewidth=1, marker='o', markersize=6, color='#CD2305')
pyplot.show()

# defines and creates the object freestream
u_inf = 1.0                                # freestream speed
alpha = 4.0                                # angle of attack (in degrees)
freestream = Freestream(u_inf, alpha)      # instantiation of the object freestream

#Builds the panel matricies
A = build_matrix(panels)                  # calculates the singularity matrix
b = build_rhs(panels, freestream)         # calculates the freestream RHS

# solves the linear system
variables = numpy.linalg.solve(A, b)

for i, panel in enumerate(panels):
    panel.sigma = variables[i]
gamma = variables[-1]

# computes the tangential velocity at each panel center.
get_tangential_velocity(panels, freestream, gamma)

# computes surface pressure coefficient
get_pressure_coefficient(panels, freestream)

# plots the surface pressure coefficient
val_x, val_y = 0.1, 0.2
x_min, x_max = min( panel.xa for panel in panels ), max( panel.xa for panel in panels )
cp_min, cp_max = min( panel.cp for panel in panels ), max( panel.cp for panel in panels )
x_start, x_end = x_min-val_x*(x_max-x_min), x_max+val_x*(x_max-x_min)
y_start, y_end = cp_min-val_y*(cp_max-cp_min), cp_max+val_y*(cp_max-cp_min)

pyplot.figure(figsize=(10, 6))
pyplot.grid(True)
pyplot.xlabel('x', fontsize=16)
pyplot.ylabel('$C_p$', fontsize=16)
pyplot.plot([panel.xc for panel in panels if panel.loc == 'extrados'], 
         [panel.cp for panel in panels if panel.loc == 'extrados'], 
         color='r', linestyle='-', linewidth=2, marker='o', markersize=6)
pyplot.plot([panel.xc for panel in panels if panel.loc == 'intrados'], 
         [panel.cp for panel in panels if panel.loc == 'intrados'], 
         color='b', linestyle='-', linewidth=1, marker='o', markersize=6)
pyplot.legend(['extrados', 'intrados'], loc='best', prop={'size':14})
pyplot.xlim(x_start, x_end)
pyplot.ylim(y_start, y_end)
pyplot.gca().invert_yaxis()
pyplot.title('Number of panels : %d' % N);
pyplot.show()

# calculates the accuracy
accuracy = sum([panel.sigma*panel.length for panel in panels])
print '--> sum of source/sink strengths:', accuracy

# calculates of the lift
cl = gamma*sum(panel.length for panel in panels)/(0.5*freestream.u_inf*(x_max-x_min))
print '--> Lift coefficient: Cl = %.3f' % cl