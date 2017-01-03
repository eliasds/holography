
data = [0 5 1; -7 1 2; 4 3 3; 2 1 4; 3 0 5; -4 -4 6; -3 -2 7; -6 -3 8; -2 -1 9];

tree = const_tree(data);

%test insert
tree.insert([2 -1 10])
assertMatrixEquals(tree.root.right.left.left.val, [2 -1]);
assertNan(tree.root.right.left.left.left);
assertNan(tree.root.right.left.left.right);

assertNan(tree.root.right.left.right);
tree.insert([4 -5 11])
assertMatrixEquals(tree.root.right.left.right.val, [4 -5]);

%test isLeaf
assertEquals(0, tree.root.isLeaf());
assertEquals(0, tree.root.left.right.isLeaf());
assertEquals(1, tree.root.left.right.right.isLeaf());

%test find
node = tree.find([-7 1]);
assertMatrixEquals(node.val, [-7 1]);
assertMatrixEquals(node.index, 2);
assertMatrixEquals(node.right.val, [-3 -2]);
assertNan(node.left);

node = tree.find([-3 -1]);
assertEquals(0, node);

%test findMin
assertMatrixEquals([-7 1], tree.findMin(1).val);
assertMatrixEquals([4 -5], tree.findMin(2).val);

miniTree = KDTree(tree.root.right);
miniTree.dim = 2;
assertMatrixEquals([0 5], miniTree.findMin(1).val);
assertMatrixEquals([4 -5], miniTree.findMin(2).val);

disp('all tests passed');
