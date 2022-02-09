using Statistics
using Random
using Pkg

# xoa comment 2 dong nay neu chua cai thu vien
# Pkg.add("CSV")
# Pkg.add("DataFrames")

using DataFrames
using CSV

mutable struct Node
    data::DataFrame 
    index::Int64
    gini::Float64
    isLeaf::Bool
    way::String
    mean::Any
    feature::Int64
    nodeTrue::Node
    nodeFalse::Node
    # Doi cau truc cua struct
    Node(data,index,gini,isLeaf,way,mean,feature) = new(data,index,gini,isLeaf,way,mean,feature)
end

#tinh entropy
function Entropy(S)
    row,col  = size(S)
    #ket qua tra ve
    iris_unique = unique(S[:,col])
    entropy = 0.0
    #xich ma 
    for value in iris_unique
        p =  length([sample for sample in eachrow(S) if sample[col] == value])/row
        if p>0
            entropy +=  -p*log2(p)
        end
    end
    return entropy
end

#tinh gain
function Gain(df, df_left, df_right)
    p_left  = size(df_left,1) / size(df,1)
    p_right = size(df_right,1) / size(df,1)
    
    return Entropy(df) - ((p_left * Entropy(df_left)) + (p_right * Entropy(df_right)))
end

#tinh gain tung cot
function ComputeGainFeature(df, Feature)

    #Lay cot can tinh
    impurity = df[:,Feature]
    
    #tim cac gia tri co trong cot
    unique_values_feature = unique(impurity)
    
    #giam impurity ( do van duc)
    gain_information = (0.,0.,0)
    
    for value_feature in unique_values_feature

        df_left  = filter(x -> (x[:][Feature] < value_feature), df)
        df_right = filter(x -> (x[:][Feature] >= value_feature), df)

        gain = Gain(df, df_left, df_right)
        
        if (gain > gain_information[2])
            gain_information = (value_feature, gain, Feature)
        end
    end

    return gain_information
end


function GetMin(ItemArray, Index)
    min     = Inf
    ret_min = (1.,1.,1.)
    for item in ItemArray
        if item[Index] < min
            min = item[Index]
            ret_min = item
        end
    end
    return ret_min
end

function GetMax(ItemArray, Index)
    max     = 0.
    ret_max = (0,0.,0.)
    for item in ItemArray
        if item[Index] > max
            max = item[Index]
            ret_max = item
        end
    end
    return ret_max
end

function BuildTree(S, NodeFrom, Nodes, Position = 0, Way = "Root")
    N, M = size(S)
    # Get the node
    features_impurity = Array{Tuple{Integer,Float64,Float64}}(undef,0)
    for j in range(1,length=M-1)
        mean_imp, gini_imp = ComputeGainFeature(S, j) 
        # mean_imp, gini_imp = GImpurity(S,j)    
        push!(features_impurity, (j, mean_imp, gini_imp))
    end

    node_min = GetMax(features_impurity,3)
    
    if (size( unique(S[:,M]) , 1 ) > 1) && (size( unique( S[:,node_min[1]] ), 1) > 1)
        node = Node(S, Position, node_min[3], false, Way, node_min[2], node_min[1])
        # Go to left - true
        BuildTree(filter(x -> x[:][node_min[1]] < node_min[2],S), node, Nodes, Position + 1, "True")
        # Go to right - false
        BuildTree(filter(x -> x[:][node_min[1]] >= node_min[2],S), node, Nodes, Position + 1, "False")
        #TODO chuyen thanh >=
    else
        node = Node(S, Position, node_min[3], true, Way, node_min[2], node_min[1])
    end
    if Way == "True"
        NodeFrom.nodeTrue = node
    end
    if Way == "False"
        NodeFrom.nodeFalse = node
    end

    push!(Nodes, node)    
end

function TrainTest(S, test_size = 0.33)

    n  = nrow(S)
    cut =  Int(round(n*test_size))

    idexs = (1:n)

    idexs  = shuffle(MersenneTwister(1234),idexs)

    train_rows =  idexs[cut+1:n]
    test_rows =  idexs[1:cut]

    train =  copy(S[train_rows,:])
    test = copy(S[test_rows,:])
    return train, test
end

function Accuracy(predictions)
    perc_right_answer = size(filter(x -> x[:][3] == true, predictions), 1) / size(predictions,1)
    return perc_right_answer * 100
end

function Predict(Test, predictions, nodes)
    Size_test   = size(Test,1)
    
    for row in eachrow(Test)
        node = GetRoot(nodes)
        while !node.isLeaf
            if row[node.feature] < node.mean
                # True
                node = node.nodeTrue
            elseif row[node.feature] >= node.mean
                # False
                #TODO: chuyen thanh >=
                node = node.nodeFalse
            end
        end
        if node.isLeaf
            pred_value  = row[size(Test,2)]
            result_node = (pred_value, unique(node.data[:,size(Test,2)])[1], unique(node.data[:,size(Test,2)])[1] == pred_value)
            push!(predictions, result_node)
        end
    end
end

function GetRoot(nodes)
    for node in nodes
        if node.way == "Root"
            return node
        end
    end
end

function TrainTree(train, nodes)
    # Create a pseudo root node
    # node_root   = Node(train, 0, 0.,false, "None", 0., 0)
    
    # Start creating the tree
    BuildTree(train, Any, nodes, 0)
end

function main_dt(file)
    # Empty array of Nodes
    nodes       = Array{Node}(undef,0)

    # Empty array of predictions
    predictions = Array{Tuple{Any,Any,Bool}}(undef,0)

    # Read dataset file
    S_dataset   = CSV.read(file,DataFrame)
    # Build 2 dataframe - train with 75% and test with 25%
    println("---- Split the data ----")
    train, test = TrainTest(S_dataset, 0.33)
    CSV.write("train.csv",train)
    CSV.write("test.csv",test)
    # Train and build a single tree
    # Input: train : dataset of train
    println("---- Train the data ----")
    TrainTree(train, nodes)
    
    # Predict the test dataset
    println("---- Predict the test data ----")
    Predict(test, predictions, nodes)

    # Get accuracy
    accu = Accuracy(predictions)
    @show accu   
end

main_dt("iris.csv")

