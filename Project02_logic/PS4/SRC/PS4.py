from os import listdir
from os.path import isfile, join



#####    Luu Y ##################

#Neu muon in ra cac buoc resolve thi bo comment nhung dong code print

#  1. thu tu cac clause co the khong giong file output yeu cau nhung van du so luong clause 

#  2. Neu muon test nhieu file input hon thi cu copy vao thu muc INPUT, chuong trinh
#     se tu dong tim danh sach file txt va doc

##################################

#doc file
def read_file(file,alpha,KB):
    f = open(file,'r')
    alpha = f.readline().strip('\n').replace(' ','').split('OR')
    a = int(f.readline())
    KB = [f.readline().strip('\n').replace(' ','').split('OR') for i in range(a)]
    check_KB(KB)
    return alpha,KB
    
#ghi file
def write_file(file,output,result):
    f = open(file,'w')
    for i in output:
        f.write(str(len(i)) + '\n')
        for j in i:
            if(j == []):
                f.write("{}\n")
            else:
                f.write(" OR ".join(j) +'\n')
    if result:
        f.write('YES')
    else:
        f.write('NO')
    f.close
    
#Kiem tra coi co clause nao trong KB bi rong khong
def check_KB(KB):
    a = len(KB)
    i=0
    while i<a:
        if KB[i] == [""]:
            KB.pop(i)
            a-=1
        else:
            i+=1

#phu dinh literal
def not_literal(literal):
    if '-' in literal:
        return literal.strip('-')
    else:
        return '-' + literal

#phu dinh alpha, neu alpha la 1 cau thi tra ve len(alpha) clause
def not_alpha(alpha):
    not_list = [not_literal(literal) for literal in alpha]
    alpha_result = []
    for literal in not_list:
        alpha_result.append([literal])
    return alpha_result

#kiem tra xem clause co can thiet khong           
def check_clause(clause):
    for i in clause:
        if not_literal(i) in clause:
            return False
    return True

#sort clause
def sort_clause(clause):
    return sorted(clause,key=lambda x: x[-1])

#kiem tra literal lap trong clause
def check_duplicate_clause(clause):
    clone = clause.copy()
    clone = set(clone)
    clone = list(clone)
    clone = sort_clause(clone)
    return clone

#kiem tra new phai con cua  clauses khong
def check_new(new, clauses):
    for i in new:
        if i not in clauses:
            return False
    return True

#noi 2 clauses lai voi nhau
def merge_clauses(new,resolvents):
    for i in resolvents:
        if i not in new:
            new.append(i)

#resolve 2 clause
def pl_resolve(clause1,clause2,new,clauses):
    resolvents = []
    for i in clause1:
        if not_literal(i) in clause2:
            
            temp1 = clause1.copy()
            temp1.remove(i)
            temp2 = clause2.copy()
            temp2.remove(not_literal(i))
            temp1.extend(temp2)

            temp1 = check_duplicate_clause(temp1)
            if check_clause(temp1):
                # if (temp1 not in clauses) and (temp1 not in new):
                #     print("("+" OR ".join(clause1)+") resolve ("+" OR ".join(clause2)+")")
                resolvents.append(temp1)
            
    return resolvents

#giai bai toan logic
def pl_resolution(KB,alpha,output):
    clauses = KB.copy()
    merge_clauses(clauses,not_alpha(alpha))
    len_clauses= len(clauses)
    while True:
        new = []

        for i in range(len(clauses)-1):
            for j in range(i+1,len(clauses)):
                resolvents = pl_resolve(clauses[i],clauses[j],new,clauses)
                merge_clauses(new,resolvents)

        if [] in new:
            merge_clauses(clauses,new)    
            output.append(clauses[len_clauses:len(clauses)])
            len_clauses= len(clauses)
            return True  
        if check_new(new,clauses) :
            output.append([])
            return False
        merge_clauses(clauses,new)
        
        output.append(clauses[len_clauses:len(clauses)])
        len_clauses= len(clauses)
        # print()

def main():
    input_file = ['./INPUT/'+f for f in listdir('./INPUT') if isfile(join('./INPUT', f))]
    output_path = './OUTPUT/output'
    for i in range(len(input_file)):
        # print(f'\nTest Case {i+1}:')
        alpha = []
        KB = []
        output = []
        alpha,KB = read_file(input_file[i],alpha,KB)
        result = pl_resolution(KB,alpha,output)
        write_file(f'{output_path}{i+1}.txt',output,result)

if __name__ == '__main__':
    main()