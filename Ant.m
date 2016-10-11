classdef Ant < handle
    
    properties
        Solution
        Samples
    end
    
    methods
        function ant = Ant(samples)
            if nargin > 0
                ant.Solution = zeros(length(samples),1);
                ant.Samples = samples;
            end
        end
        
        function travel(obj, probability, q)
            for i = 1 : length(obj.Solution)
                obj.Solution(i) = obj.selectCluster(probability(i,:), q);
            end
        end
        
        function selected = selectCluster(obj, probability, q)
            qr = rand();
            if qr <= q
                max_prob =  max(probability);
                max_prob = max_prob(1);
                probabilities = probability(probability == max_prob);
                selected = 1;
                if length(probabilities) > 1
                    selected = randi([1, length(probabilities)]);
                end
            else
                %pemilihan sesuai probabilitas
                c = cumsum(probability);
                rn = rand();
                cc = c(c >= rn);
                selected = find(c == cc(1));
                selected = selected(1);
            end
        end
        
        function fitness = calculateFitness(obj, n_cluster)
            fitness = 0;
            samples = obj.Samples;
            for i = 1 : n_cluster
                x = samples(obj.Solution == i,:);
                if isempty(x)
                    continue
                end
                centroid = sum(x,1) / size(x,1);
                for j = 1 : size(x,2)
                   x(:,j) = ( x(:,j) - centroid(j) ) .^ 2;
                end
%                 fitness = fitness + sum(  sum(x') );
                fitness = fitness + sum( sqrt( sum(x') ) );
            end
        end
        
        function fitness = localSearch(obj, p1s, n_cluster)
            samples = obj.Samples;
            probs = rand( size(samples, 1) , 1 );
            selected = find(probs <= p1s);
            old_solution = obj.Solution;
            old_fitness = obj.calculateFitness(n_cluster);
            for i = selected
                r = randi([1 n_cluster-1]);
                if r >= obj.Solution(i)
                    r = r + 1;
                end
                obj.Solution(i) = r;
            end
            fitness = obj.calculateFitness(n_cluster);
            if fitness > old_fitness
                obj.Solution = old_solution;
                fitness = old_fitness;
            end
        end
                
        function tao = globalUpdatePheromones(obj, tao, fitness)
            updateValue = 1 / fitness;
            
            for i = 1 : length(obj.Solution)
               j = obj.Solution(i);
               tao(i,j) = tao(i,j) + updateValue;
            end
        end
    end
end