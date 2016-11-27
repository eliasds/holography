% Nearest neighbor test

points = [1 2 5 1; -3 -2 -1 2; 5 3 2 3; 0 3 -5 4; 3 1 1 5; -3 -1 0 6; 1 1 6 7; 9 3 1 8; 3 1 -2 9];

my_point = [0 1 6];     %Closest is [1 1 6]

tree = const_tree(points, 1);

[particle, index] = nearest_neighbor(tree, my_point, Data(nan), Data(realmax), Data(-1)) %Should be [1 1 6] and 7
%node = nearest_neighbor(tree, my_point)

data = [0 0 0; 3 1 1; 2.5 5 1; 3.5 7 2; 7 3 2; 8 5 1; 10 4 2];
%data is 3-tuples; have to give it an index value
for i = 1:size(data, 1)
    data(i, 4) = i;
end

P = [4 1.5 1];  %Should be [3 1 1]

tree = const_tree(data, 1);

[particle, index] = nearest_neighbor(tree, P, Data(nan), Data(realmax), Data(-1))       % Should be [3 1 1] and 2
%node = nearest_neighbor(tree, P)