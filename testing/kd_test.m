
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

%test findMin after modifying tree
newTree = KDTree(tree.root.right);
newTree.dim = 2;
assertMatrixEquals([0 5], newTree.findMin(1).val);
assertMatrixEquals([4 -5], newTree.findMin(2).val);

miniTree = KDTree(tree.root.right);
miniTree.dim = 2;
assertMatrixEquals([0 5], miniTree.findMin(1).val);
assertMatrixEquals([4 -5], miniTree.findMin(2).val);

%test delete leaf
assertNotNan(tree.root.left.left);
tree.delete([-4 -4]);
assertMatrixEquals([-6 -3], tree.root.left.val);
assertNan(tree.root.left.left);

%test delete with one child
assertNotNan(tree.root.left.right);
assertNotNan(tree.root.left.right.right);
assertMatrixEquals([-7 1], tree.root.left.right.val);
assertMatrixEquals([-3 -2], tree.root.left.right.right.val);
tree.delete([-7 1]);
assertNotNan(tree.root.left.right);
assertNan(tree.root.left.right.right);
assertMatrixEquals([-3 -2], tree.root.left.right.val);

%test delete at junction
assertNotNan(tree.root.right);
assertNotNan(tree.root.right.right.right);
assertMatrixEquals([2 1], tree.root.right.val);
assertMatrixEquals([0 5], tree.root.right.right.val);
assertMatrixEquals([4 3], tree.root.right.right.right.val);
tree.delete([2 1]);
assertNan(tree.root.right.right.right);
assertMatrixEquals([4 3], tree.root.right.val);
assertMatrixEquals([0 5], tree.root.right.right.val);

%delete one more
assertNotNan(tree.root.right.right);
tree.delete([0 5]);
assertNan(tree.root.right.right);

%test left leaning delete
assertNan(tree.root.right.right);
assertNotNan(tree.root.right.left);
tree.delete([4 3]);
assertNan(tree.root.right.left);
assertNotNan(tree.root.right.right);
assertNotNan(tree.root.right.right.left);
assertMatrixEquals([4 -5], tree.root.right.val);
assertMatrixEquals([3 0], tree.root.right.right.val);
assertMatrixEquals([2 -1], tree.root.right.right.left.val);

disp('all tests passed');
