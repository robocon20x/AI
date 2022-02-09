import heuristic as hx

def gbfs_bonus(start,end,matrix,bonus_points,flag):
    open = [] # hang doi
    close = [] # cac o da chay
    path = {} # luu quan he cha con giua cac o 
    result_path = []
    result_path_temp = []
    open.append(start)
    while len(open) > 0:
        
        min = hx.heuristic(open[0],end,flag)
        pos = 0
        pos_b = -1
        
        for i in range(len(open)):
            for j in range(len(bonus_points)):
                distace = bonus_points[j][2] + hx.heuristic(open[i],(bonus_points[j][0],bonus_points[j][1]),flag) + hx.heuristic((bonus_points[j][0],bonus_points[j][1]),end,flag)# diem thuong + khoang cach den diem dang xet + khoang cach tu bonus_point[i] den end
                if distace < min:
                    min = distace
                    pos = i
                    pos_b = j
        if pos_b == -1:
            for i in range(len(open)):
                if hx.heuristic(open[i],end,flag) < min:
                    min = hx.heuristic(open[i],end,flag)
                    pos = i 
        curCell=open.pop(pos)
        close.append(curCell)
        if curCell == end:
            break
        if pos_b != -1:
            if curCell == (bonus_points[pos_b][0],bonus_points[pos_b][1]):
                bonus_points.pop(pos_b)
                close.remove(curCell)
                result_path_temp = gbfs_bonus(curCell,end,matrix,bonus_points,flag)
                break
        
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
    curCell = close[-1]  
    while(curCell != start):
        result_path.append(curCell)
        curCell = path[curCell]
    result_path.append(curCell)
    result_path.reverse()
    result_path.extend(result_path_temp)
    return result_path