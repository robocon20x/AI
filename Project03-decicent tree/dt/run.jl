#####NOTE: 
# code nay chi chay duoc voi tap du lieu iris.csv, neu dung cho tap du lieu co feature type
# khac float thi se bi loi
##########

using Statistics
using Random
using Pkg

# xoa comment 2 dong nay neu chua cai thu vien
# Pkg.add("CSV")
# Pkg.add("DataFrames")

using DataFrames
using CSV

#chia data
function TrainTest(df, test_size = 0.25)
    n  = nrow(df)
    flag =  Int(round(n*test_size))
    idexs = (1:n)
    idexs  = shuffle(MersenneTwister(1234),idexs)

    train_rows =  idexs[flag+1:n]
    test_rows =  idexs[1:flag]

    train =  copy(df[train_rows,:])
    test = copy(df[test_rows,:])
    return train, test
end

# entropy
function entropy(df)
    result  = df[:,2]
    result_uniques = unique(result)

    entropy = 0.
    for result_unique in result_uniques
        p = count(x -> x == result_unique, result) / size(df,1)
        entropy += -p * log2(p)
    end
    return entropy
end

function Gain(df, feature)
    
    unique_values = unique(df[:,1])
    #giam impurity
    max_gain = (0.,0,1)
    for unique_value in unique_values
       
        df_less  = filter(x -> x[:][1] < unique_value, df)
        df_greater = filter(x -> x[:][1] >= unique_value, df)    

        gain = entropy(df) - (
            ( size(df_less,1) / size(df,1) ) * entropy(df_less)
           +( size(df_greater,1) / size(df,1) ) * entropy(df_greater)
        )
        #dung G nen tim max
        if (gain > max_gain[1])
            max_gain = (gain, feature, unique_value)
        end

    end
    return max_gain

end

#tao node
function createNode(df, divider, feature, way, node_left, node_right, isLeaf)
    node = [df,divider,feature,way,node_left,node_right,isLeaf]
    return node
end

#xay dung cay
function buildtree(df, way = "Root")
    col = ncol(df)

    # Neu la leaf thi khong can phai chia nua   
    if ( size( unique(df[:,col]) , 1) == 1 )
        node = createNode(df, 0, 0, way, 0, 0, true)
        push!(nodes, node)
        return size(nodes,1)
    end

    #chon feature
    gains = []
    for i in 1:(col-1)
        gain = Gain(df[:,[i,col]], i)
        push!( gains, gain ) 
    end
    
    max_gain = gains[1]
    for gain in gains
        if (gain[1] > max_gain[1])
            max_gain = gain
        end
    end
    
    gain, feature, divider = max_gain
    
    #chia dataframe theo gia tri divider
    df_less  = filter(x -> x[:][feature] < divider, df)
    df_greater = filter(x -> x[:][feature] >=  divider, df) 

    #de quy tao cay
    node_left  = buildtree(df_less, "L")
    node_right = buildtree(df_greater, "R")

    node = createNode(df, divider, feature, way, node_left, node_right, false)
    push!(nodes, node)

    return size(nodes,1)  
end

#tim root
function getbegginner()
    for node in nodes
        if (node[4] == "Root")
            return node
        end
    end
end

#Du doan ket qua tung row trong test roi luu vao predictions
function Predict(Test, predictions)
    col_test   = ncol(Test)

    for row in eachrow(Test)
        node = getbegginner()
        #neu khong phai leaf
        while node[7] == false
            if  row[node[3]] <= node[2]
                # nodeTrue
                node = nodes[node[5]]
            else
                # nodeFalse
                node = nodes[node[6]]
            end
            
        end
        #neu la leaf, du doan ket qua 
        if node[7] == true
            pred_value_test  = row[col_test]
            pred_value_tree  = unique(node[1][:,col_test])[1]
            pred_value_check = row[col_test] == unique(node[1][:,col_test])[1]
            
            result_node = (pred_value_test, pred_value_tree, pred_value_check)
            push!(predictions, result_node)
        end
        
    end
end

function traindt(df)
    buildtree(df)
end

####main

#tree
nodes = []
#chuoi ket qua du doan
predictions = Array{Tuple{Any,Any,Bool}}(undef,0)
#doc file vao dataframe
df_main   = CSV.read("iris.csv",DataFrame)

# chia dataframe thanh 2 nua, train 2/3 va test 1/3

train, test = TrainTest(df_main, 0.333)

println("training rows: $(nrow(train))\ntest rows: $(nrow(test))")

#xuat ra 2 file csv cua train va test data
# CSV.write("train.csv",train)
# CSV.write("test.csv",test)

# train data va tao cay phan loai
traindt(train)

# du doan ket qua cua test data
Predict(test, predictions)

mape = []

for i in predictions
    push!(mape,i[3])
end

accuracy    = 100* (sum(mape)/size(predictions, 1))
@show accuracy