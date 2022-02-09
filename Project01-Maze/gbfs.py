import heuristic as hx

def gbfs(start,end,matrix,flag):
    open = [] # hang doi
    close = [] # cac o da chay
    path = {} # luu quan he cha con giua cac o 
    open.append(start)
    while len(open) > 0:
        fx = [hx.heuristic(open[i],end,flag) for i in range(len(open))]
        pos = fx.index(min(fx))
        curCell=open.pop(pos)
        close.append(curCell)
        #neu no la diem cuoi thi ket thuc
        if curCell == end:
            break
        #tim xung quanh diem dang dung
        if matrix[curCell[0]][curCell[1]+1] != 'x': #phai
            childCell = (curCell[0],curCell[1]+1)
            if childCell not in close and childCell not in open:
                path[childCell] = curCell
                open.append(childCell)
        if matrix[curCell[0]][curCell[1]-1] != 'x': #trai
            childCell = (curCell[0],curCell[1]-1)
            if childCell not in close and childCell not in open:
                path[childCell] = curCell
                open.append(childCell)
        if matrix[curCell[0]+1][curCell[1]] != 'x': #xuong
            childCell = (curCell[0]+1,curCell[1])
            if childCell not in close and childCell not in open:
                path[childCell] = curCell
                open.append(childCell)
        if matrix[curCell[0]-1][curCell[1]] != 'x': #len
            childCell = (curCell[0]-1,curCell[1])
            if childCell not in close and childCell not in open:
                path[childCell] = curCell
                open.append(childCell)
    #xu ly close
    result_path = []
    curCell = close[-1]  
    while(curCell != start):
        result_path.append(curCell)
        curCell = path[curCell]
    result_path.append(curCell)
    result_path.reverse()
    travel = len(close) + len(open)
    
    return result_path,travel