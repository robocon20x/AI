using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")

using CSV
using DataFrames
using Random


mutable struct DTNode
    attribute::String
    split::Float64
    left::Union{DTNode, Nothing}
    right::Union{DTNode, Nothing}
    isLeaf::Bool
    predict::String
end
#default constructor
DTNode() = DTNode("",0.0,nothing,nothing,false,"")
function DTNode()
    return DTNode("",0.0,nothing,nothing,false,"")

function Entropy(dataset)
    entropy = 0
    classValue = ["Setosa", "Versicolor", "Virginica"]
    for value in classValue
        p = length([sample for sample in dataset if sample["variety"] == value])/length(dataset)
        if p > 0
            entropy +=  -p*log2(p)
        end
    end
    return entropy
end

function AvgEntropy(dataset, attribute, splitValue)
    avgEntropy = 0.0
    lessSet = [sample for sample in dataset if sample[attribute] < splitValue]
    greaterSet = [sample for sample in dataset if sample[attribute] >= splitValue]
    p1 = length(lessSet)/length(dataset)
    p2 = length(greaterSet)/length(dataset)
    avgEntropy = p1*Entropy(lessSet) + p2*Entropy(greaterSet)
    return avgEntropy
end

function PickMinAttribute(dataset, attributeList, attributeValues, node)
    minAvgEntropy = typemax(Float64)
    selectedAttribute = ""
    minSplit = 0.0
    for attr in attributeList
        for splitValue in attributeValues[attr]
            avgEntropy = AvgEntropy(dataset,attr,splitValue)
            if avgEntropy < minAvgEntropy
                minAvgEntropy = avgEntropy
                selectedAttribute = attr
                minSplit = splitValue
            end
        end
    end
    node.attribute = selectedAttribute
    node.split = minSplit
    return selectedAttribute
end
function NodeBuild(node, dataset, attributeList)
    classAttribute = "variety"
    classValues = ["Setosa", "Versicolor", "Virginica"]
    #all dataset belong to the same class
    if Entropy(dataset) == 0
        node.isLeaf = true
        node.predict = dataset[1][classAttribute]
        return
    end
    #if all the attribute have been selected
    if length(attributeList) == 0
        node.isLeaf = true
        freq = Dict()
        for sample in dataset
            freq[sample[classAttribute]] = get(freq,sample[classAttribute],0) + 1
        end
        most = ""
        max = 0
        #find the most frequent class value
        for value in classValues
            if haskey(freq,value) && max < freq[value]
                max = freq[value]
                most = value
            end
        end
        node.predict = most
        return
    end
    #Get all different values in a attribute
    attributeValues = Dict()
    for attr in attributeList
        values = Set()
        for sample in dataset
            push!(values,sample[attr])
        end
        attributeValues[attr] = values
    end
    selectedAttribute = PickMinAttribute(dataset,attributeList,attributeValues,node)
    lessSet = [sample for sample in dataset if sample[selectedAttribute] < node.split]
    greaterSet = [sample for sample in dataset if sample[selectedAttribute] >= node.split]
    newAttributeList = filter(attr -> attr != selectedAttribute, attributeList)
    if length(lessSet) > 0
        node.left = DTNode()
        NodeBuild(node.left,lessSet,newAttributeList)
    end
    if length(greaterSet) > 0
        node.right = DTNode()
        NodeBuild(node.right,greaterSet,newAttributeList)
    end
end

function Predict(sample, node)
    if node.isLeaf
        return node.predict
    end
    if sample[node.attribute] < node.split
        Predict(sample,node.left)
    else
        Predict(sample,node.right)
    end
end


function ReadFile(filename)
    attributeName = []
    dataset = []
    open(filename, "r") do reader
        #remove the " character
        firstLine = replace(readline(reader), "\"" => "")
        attributeName = filter(attr -> attr != "variety",split(firstLine, ","))
        for line in eachline(reader)
            sample = Dict()
            line = split(line,",")
            for i in 1:length(line)-1
                sample[attributeName[i]] = parse(Float64, line[i])
            end
            sample["variety"] = replace(line[end], "\"" => "")
            push!(dataset, sample)
        end
    end
    return attributeName, dataset
end

function BuildTree(dataset, attributeList)
    root = DTNode()
    NodeBuild(root,dataset,attributeList)
    return root
end

function AccuracyCacl(dataset, root)
    accuracy = 0.0
    for sample in dataset
        if sample["variety"] == Predict(sample,root)
            accuracy += 1
        end
    end
    return 100*(Float64(accuracy)/length(dataset))
end

#main

attributeList, dataset = ReadFile("iris.csv")
rng = MersenneTwister(1234)

trainingSize = floor(Int,2/3*length(dataset))
training = shuffle(rng,dataset)[1:trainingSize]

test = filter(sample -> !(sample in training),dataset)

println("training leghth: $(length(training))\ntest length: $(length(test))")

root = BuildTree(dataset,attributeList)

print("Accuracy: ",AccuracyCacl(test,root))