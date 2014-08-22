function OrgTree(tree, currentNodeId) {
  this.tree = this.augmentTree(tree, currentNodeId, false);
}

OrgTree.prototype.augmentTree = function(node, currentNodeId, disabled) {
  var self = this;

  if (node.id === currentNodeId) { disabled = true; }

  return {
    id: node.id,
    name: node.name,
    url: node.url,
    disabled: disabled,
    children: node.children.map(function(child) {
      return self.augmentTree(child, currentNodeId, disabled);
    })
  };
};

OrgTree.prototype.pathToNodeId = function(id, node, path) {
  var self = this;

  node = node || self.tree;
  path = path || [node];

  if (!id) { return [self.tree]; }
  if (node.id === id) { return path; }

  for (var i = 0, ii = node.children.length; i < ii; i++) {
    var child = node.children[i];
    var res = self.pathToNodeId(id, child, path.concat(child));
    if (res) { return res; }
  }

  return null;
};
