% Nearest neighbor test

points = [1 2 5; -3 -2 -1; 5 3 2; 0 3 -5; 3 1 1; -3 -1 0; 1 1 6; 9 3 1; 3 1 -2];

my_point = [0 1 6];     %Closest is [1 1 6]

tree = const_tree(points, 1);

nearest_neighbor(tree, my_point, Data(nan), Data(realmax))

data = [0 0 0; 3 1 1; 2.5 5 1; 3.5 7 2; 7 3 2; 8 5 1; 10 4 2];
P = [4 1.5 1];  %Should be [3 1 1]

tree = const_tree(data, 1);

nearest_neighbor(tree, P, Data(nan), Data(realmax))       %Should be [3 1 1]