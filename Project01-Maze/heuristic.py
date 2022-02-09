from math import sqrt

def heuristic(start,end,flag):
    if 1 == flag: #manhattan
        dx = abs(start[0] - end[0])
        dy = abs(start[1] - end[1])
        return dx + dy
    if 2 == flag: #euclidean
        dx = abs(start[0] - end[0])
        dy = abs(start[1] - end[1])
        return sqrt(dx * dx + dy * dy)
    if 3 == flag: #chebyshev
        dx = abs(start[0] - end[0])
        dy = abs(start[1] - end[1])
        return (dx +dy) + (-1) * min(dx,dy)
    if 4 == flag: #octile
        dx = abs(start[0] - end[0])
        dy = abs(start[1] - end[1])
        return (dx +dy) + (sqrt(2)-2) * min(dx,dy)
