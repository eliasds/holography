
% Test of KDTree's bounded implementation. Note that this test is in 2
% dimensions, although I typically use 3 dimensions in practice.

data = [-5 -8 1; -10 -4 2; -12 -1 3; -4 -3 4; -8 14 5; -7 3 6; -10 1 7; 
    -11 9 8; -4 7 9; 1 -1 10; 8 3 11; 6 8 12; 5 11 13; 3 1 14; 4 -3 15; 
    6 -5 16; 12 -10 17; 9 -2 18; 15 -7 20];
tree = const_bounded_tree(data);

%test tree initialization
assertMatrixEquals([1 -1], tree.root.val);
assertMatrixEquals([-10 1], tree.root.left.val);
assertMatrixEquals([-10 -4], tree.root.left.left.val);
assertMatrixEquals([-12 -1], tree.root.left.left.left.val);
assertMatrixEquals([-5 -8], tree.root.left.left.right.val);
assertMatrixEquals([-4 -3], tree.root.left.left.right.right.val);
assertMatrixEquals([-8 14], tree.root.left.right.val);
assertMatrixEquals([-11 9], tree.root.left.right.left.val);
assertMatrixEquals([-7 3], tree.root.left.right.right.val);
assertMatrixEquals([-4 7], tree.root.left.right.right.right.val);
assertMatrixEquals([9 -2], tree.root.right.val);
assertMatrixEquals([6 -5], tree.root.right.left.val);
assertMatrixEquals([4 -3], tree.root.right.left.left.val);
assertMatrixEquals([12 -10], tree.root.right.left.right.val);
assertMatrixEquals([15 -7], tree.root.right.left.right.right.val);
assertMatrixEquals([5 11], tree.root.right.right.val);
assertMatrixEquals([3 1], tree.root.right.right.left.val);
assertMatrixEquals([8 3], tree.root.right.right.right.val);
assertMatrixEquals([6 8], tree.root.right.right.right.right.val);

infty = 1000;       %TODO

%test bounds initialization
assertMatrixEquals([-4 3; -infty infty], tree.root.bounds);
assertMatrixEquals([-infty 1; -1 3], tree.root.left.bounds);
assertMatrixEquals([-12 -5; -infty 1], tree.root.left.left.bounds);
assertMatrixEquals([-infty -10; -infty 1], tree.root.left.left.left.bounds);
assertMatrixEquals([-10 1; -infty -3], tree.root.left.left.right.bounds);
assertMatrixEquals([-10 1; -8 1], tree.root.left.left.right.right.bounds);
assertMatrixEquals([-11 -7; 1 infty], tree.root.left.right.bounds);
assertMatrixEquals([-infty -8; 1 infty], tree.root.left.right.left.bounds);
assertMatrixEquals([-8 1; 1 7], tree.root.left.right.right.bounds);
assertMatrixEquals([-8 1; 3 infty], tree.root.left.right.right.right.bounds);
assertMatrixEquals([1 infty; -3 1], tree.root.right.bounds);
assertMatrixEquals([4 12; -infty -2], tree.root.right.left.bounds);
assertMatrixEquals([1 6; -infty -2], tree.root.right.left.left.bounds);
assertMatrixEquals([6 infty; -infty -7], tree.root.right.left.right.bounds);
assertMatrixEquals([6 infty; -10 -2], tree.root.right.left.right.right.bounds);
assertMatrixEquals([3 6; -2 infty], tree.root.right.right.bounds);
assertMatrixEquals([1 5; -2 infty], tree.root.right.right.left.bounds);
assertMatrixEquals([5 infty; -2 8], tree.root.right.right.right.bounds);
assertMatrixEquals([5 infty; 3 infty], tree.root.right.right.right.right.bounds);

%test isKDified
assertTrue(tree.isKDified(tree.root.right.left, [8 -6]));
assertTrue(tree.isKDified(tree.root.right.left, [10 -5]));
assertFalse(tree.isKDified(tree.root.right.left, [3 -5]));
assertTrue(tree.isKDified(tree.root, [1 -3]));
assertTrue(tree.isKDified(tree.root, [2.75 -1.75]));
assertFalse(tree.isKDified(tree.root, [4 -1]));
assertTrue(tree.isKDified(tree.root.left.right.right, [-2, 5]));

%test insertion
tree.insert([8 -6 21]);
assertMatrixEquals([8 -6], tree.root.right.left.right.right.left.val);
assertMatrixEquals([6 15; -10 -2], tree.root.right.left.right.right.left.bounds);
assertMatrixEquals([4 8; -infty -2], tree.root.right.left.bounds);
assertMatrixEquals([6 infty; -infty -7], tree.root.right.left.right.bounds);
assertMatrixEquals([8 infty; -10 -2], tree.root.right.left.right.right.bounds);

tree.insert([9, 2, 22]);
assertMatrixEquals([9 2], tree.root.right.right.right.left.val);
assertMatrixEquals([5 infty; -2 3], tree.root.right.right.right.left.bounds);
assertMatrixEquals([5 infty; 2 8], tree.root.right.right.right.bounds);

assertMatrixEquals([-4 3; -infty infty], tree.root.bounds);
assertMatrixEquals([1 infty; -3 1], tree.root.right.bounds);
assertMatrixEquals([3 6; -2 infty], tree.root.right.right.bounds);

%test deletion

%test changeVal

disp('all tests passed.');
