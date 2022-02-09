import pandas as pd
def dfs(start,end,matrix):
    open = [] # hang doi
    close = [] # cac bien da chay
    dfsPath = {} # luu coi ai la bien truoc cua no
    open.append(start)
    close.append(start)

    while len(open) >0:
        curCell=open.pop()
        if curCell == end:
            break
        if matrix[curCell[0]][curCell[1]+1] != 'x': #(x,y+1) phai
            childCell = (curCell[0],curCell[1]+1)
            if childCell not in close:                
                close.append(childCell)
                open.append(childCell)
                dfsPath[childCell] = curCell
        if matrix[curCell[0]][curCell[1]-1] != 'x': #(x,y-1) trai
            childCell = (curCell[0],curCell[1]-1)
            if childCell not in close:                
                close.append(childCell)
                open.append(childCell)
                dfsPath[childCell] = curCell
        if matrix[curCell[0]+1][curCell[1]] != 'x': #(x+1,y) xuong
            childCell = (curCell[0]+1,curCell[1])
            if childCell not in close:
                close.append(childCell)
                open.append(childCell)
                dfsPath[childCell] = curCell
        if matrix[curCell[0]-1][curCell[1]] != 'x': #(x-1,y) len
            childCell = (curCell[0]-1,curCell[1]) 
            if childCell not in close:
                close.append(childCell)
                open.append(childCell)
                dfsPath[childCell] = curCell

        
    fwdPath=[] #con duong tim duoc
    end_temp = end
    start_temp = start
    while end_temp != start_temp:
        fwdPath.append(end_temp)
        end_temp = dfsPath[end_temp]
    fwdPath.append(start)

    fwdPath.reverse()
    open.extend(close)
    travel = pd.unique(open).tolist()
    return fwdPath,len(travel)