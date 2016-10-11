rng('shuffle');

samples = csvread('iris.csv');

n_cluster = 3;
init_tao = 0.01;
rho = 0.01;
ant_quantity = 50;
max_cycle = 1000;
p1s = 0.01;
q = 0.98;
best_quantity = round(ant_quantity * 20/100);

%inisialisasi tao
tao = zeros(size(samples,1), n_cluster);
tao(tao==0) = init_tao;


ants(ant_quantity,1) = Ant(samples);
for i = 1 : length(ants)
    ants(i) = Ant(samples);
end

best_fitness = intmax;
best_fitness_ = intmax;
best_solution = [];
best_fitness_cycle = zeros(max_cycle, 1);
iteration_best_fitness_cycle = zeros(max_cycle, 1);
fitnesses = zeros(ant_quantity, 1);

cycle = 1;
while cycle <= max_cycle
    probability = bsxfun(@rdivide,tao,sum(tao')');
    for i = 1 : length(ants)
       ants(i).travel(probability, q);
    end

    for i = 1 : length(ants)
        fitnesses(i) = ants(i).calculateFitness(n_cluster);
    end
    
    sorted = sort(fitnesses);
    best_fitnesses = sorted(1:best_quantity);
    best_ant_idx = find(ismember(fitnesses, best_fitnesses))';
    
    for i = best_ant_idx
        fitnesses(i) = ants(i).localSearch(p1s, n_cluster);
    end
    
    tao = (1 - rho) * tao;
    for i = best_ant_idx
        tao = ants(i).globalUpdatePheromones(tao, fitnesses(i) );
    end
      
    best_fitness_ = min(fitnesses);
    if best_fitness_ <= best_fitness
       best_fitness = best_fitness_;
       idx = find(fitnesses == best_fitness_);
       idx = idx(1);
       best_solution = ants( idx ).Solution;
    end

    best_fitness_cycle(cycle) = best_fitness;
    iteration_best_fitness_cycle(cycle) = best_fitness_;
    
    fprintf('cycle: %d/%d, best fitness: %f, iteration best fitness: %f\n', cycle, max_cycle, best_fitness, best_fitness_);

    cycle = cycle + 1;
end

close
figure('position',[700 100 600 800])

subplot(2,2,1)
plot(best_fitness_cycle);

subplot(2,2,2)
histogram(best_solution);

subplot(2,2,[3 4])
for i = 1 : n_cluster
    idx = find(best_solution == i);
    if isempty(idx)
        continue
    end
    scatter3( samples(idx,1) , samples(idx,2) , samples(idx,3) );
    hold on
end
hold off