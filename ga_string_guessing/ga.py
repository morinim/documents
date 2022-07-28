#!/usr/bin/env python3
import random
import statistics

GENESET = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"
target = "Hello World"

def generate_base_population(size):
    population = dict()
    target_size = len(target)

    while len(population) < size:
        population[random_individual(target_size)] = -1  # unknown fitness

    return population


def tournament_child(population, pressure = 4):
    participants = random.sample(population.keys(), pressure)
    return max(participants, key = lambda k: population[k])


def roulette_child(population):
    pick = random.uniform(0, sum(population.values()))
    current = 0

    for pop in population:
        current += population[pop]
        if current > pick:
            return pop


def generate_new_population(population, choose,
                            crossover_rate = 0.7, mutation_rate = 0.01):
    new_population = dict()

    while len(new_population) < len(population):
        child1 = choose(population)
        child2 = choose(population)

        if random.random() < crossover_rate:
            child1, child2 = crossover(child1, child2)

        if random.random() < mutation_rate:
            child1 = mutate(child1)
            child2 = mutate(child2)

        new_population[child1] = -1
        new_population[child2] = -1

    while len(new_population) > len(population):
        new_population.popitem()

    return new_population


def assign_fitness(population):
    for x in population:
        population[x] = fitness(x)


def random_individual(length):
    return ''.join(random.choices(GENESET, k = length))


def fitness(candidate):
    fitness = 0
    for i in range(len(candidate) - 1):
        if target[i] == candidate[i]:
            fitness += 1
    return fitness


def mutate(individual):
    i = random.randint(0, len(individual) - 1)
    return individual[:i] + random.choice(GENESET) + individual[i + 1:]


def crossover(parent1, parent2):
    i = random.randint(1, len(target) - 1)
    return parent1[:i] + parent2[i:], parent2[:i] + parent1[i:]


def evolution(population_size = 300, choose = tournament_child):
    population = generate_base_population(population_size)
    generations = 0;

    while target not in population:
        assign_fitness(population)
        population = generate_new_population(population, choose)
        generations += 1

    return generations


def main():
    generations = []
    num = 100

    for run in range(num):
        found_at = evolution(choose = tournament_child)
        print(run, found_at)
        generations.append(found_at)

    print(statistics.mean(generations), statistics.stdev(generations))


if __name__ == "__main__":
    main()
