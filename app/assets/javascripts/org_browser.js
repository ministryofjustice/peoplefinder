/* global angular, document, $ */
var peoplefinderApp = angular.module('peoplefinderApp', ['ngAnimate']);

peoplefinderApp.injectNewContainer = function(container) {
  angular.element(document).injector().invoke(function ($compile) {
    var scope = angular.element(container).scope();
    $compile(container)(scope);
  }, this);
};

function FormInputMapper(element) {
  this._hiddenInput = $(element).find('input[type="hidden"]');
  this.active = !!this._hiddenInput.length;
}

FormInputMapper.prototype.getId = function() {
  return parseInt(this._hiddenInput.attr('value'), 10);
};

FormInputMapper.prototype.setId = function(id) {
  if (!this.active) { return; }
  this._hiddenInput.attr('value', id);
};

peoplefinderApp.controller('OrgBrowserCtrl', function($scope, $element, $http) {
  var augmentTree = function(node, current, disabled) {
    if (node.id === current) { disabled = true; }
    return {
      id: node.id,
      name: node.name,
      url: node.url,
      disabled: disabled,
      children: node.children.map(function(child) {
        return augmentTree(child, current, disabled);
      })
    };
  };

  var pathToNodeId = function(node, id, path) {
    path = path || [node];

    if (node.id === id) { return path; }

    for (var i = 0, ii = node.children.length; i < ii; i++) {
      var child = node.children[i];
      var res = pathToNodeId(child, id, path.concat(child));
      if (res) { return res; }
    }

    return null;
  };

  $scope.moveDown = function(group) {
    if (group.disabled) { return; }
    if ($scope.isExpandable(group)) {
      $scope.groups.push(group);
    }
    $scope.select(group);
  };

  $scope.moveUp = function(group) {
    if (group.disabled) { return; }
    while ($scope.current !== group) { $scope.groups.pop(); }
    $scope.select(group);
  };

  $scope.isExpandable = function(group) {
    return group.children.length > 0;
  };

  $scope.isSelected = function(group) {
    return group.id === $scope.selectedId;
  };

  $scope.select = function(group) {
    $scope.selectedId = group.id;
    $scope.mapper.setId(group.id);
  };

  Object.defineProperty(
    $scope, 'current',
    { get: function() { return $scope.groups[$scope.groups.length - 1]; } }
  );

  $scope.groups = [];

  $scope.mapper = new FormInputMapper($element);

  if ($scope.mapper.active) {
    $scope.selectMode = true;
    $scope.selectedId = $scope.mapper.getId();
  }

  $http.get('/org.json').success(function(tree) {
    var current;

    if ($scope.selectMode) {
      current = parseInt($element.attr('data-current-id'), 10);
    }

    tree = augmentTree(tree, current, false);
    var path;
    if ($scope.selectMode && $scope.selectedId) {
      path = pathToNodeId(tree, $scope.selectedId);
      $scope.select(path[path.length - 1]);
    } else {
      path = [tree];
    }
    path.forEach(function(group) { $scope.moveDown(group); });
  });
});
