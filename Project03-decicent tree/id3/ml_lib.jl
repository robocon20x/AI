function mutate(value, mutation_percent_range, number_of_mutations)
    output = []
    for i in 1:number_of_mutations
        mutation = value * (1 + (rand(mutation_percent_range) / 100))
        push!(output, mutation)
    end
    output
end

function distance(first_vector, second_vector, power = 2)
    total = 0
    for i in 1:length(first_vector)
        total += abs(second_vector[i] - first_vector[i]) ^ power
    end
    total ^ (1 / power)
end

function counter(array_of_elements)
    counts = Dict()

    for element in array_of_elements
        counts[element] = get(counts, element, 0) + 1
    end

    counts
end

function highest_vote(counts)
    max_val = 0
    max_vote = ""

    for (key, value) in counts
        if value > max_val
            max_val = value
            max_vote = key
        end
    end

    max_vote
end

function element_probabilities(array_of_elements)
    probabilities = Dict()
    number_of_elements = length(array_of_elements)
    
    for (key, value) in counter(array_of_elements)
        probabilities[key] = value / number_of_elements
    end

    probabilities
end

function entropy(array_of_elements)
    probabilities = element_probabilities(array_of_elements)
    output = 0
    
    for (_key, value) in probabilities
        output -= value * log2(value)
    end
    
    output
end
