/* global angular, document, OrgTree, FormInputMapper */

var peoplefinderApp = angular.module('peoplefinderApp', ['ngAnimate']);

peoplefinderApp.injectNewContainer = function(container) {
  angular.element(document).injector().invoke(function ($compile) {
    var scope = angular.element(container).scope();
    $compile(container)(scope);
  }, this);
};

peoplefinderApp.controller('OrgBrowserCtrl', function($scope, $element, $http) {
  var initialize = function() {
    $scope.groups = [];
    $scope.mapper = new FormInputMapper($element);
    $scope.selectMode = $scope.mapper.active;
    if ($scope.selectMode) { $scope.selectedId = $scope.mapper.getId(); }
    $http.get('/org.json').success(jsonLoaded);
  };

  var jsonLoaded = function(tree) {
    var current, path;

    if ($scope.selectMode) {
      current = parseInt($element.attr('data-current-id'), 10);
    }

    var orgTree = new OrgTree(tree, current);

    if ($scope.selectMode && $scope.selectedId) {
      path = orgTree.pathToNodeId($scope.selectedId);
      $scope.select(path[path.length - 1]);
    } else {
      path = orgTree.pathToRoot();
    }
    path.forEach(function(group) { $scope.moveDown(group); });
  };

  $scope.moveDown = function(group) {
    if (group.disabled) { return; }
    if ($scope.isExpandable(group)) { $scope.groups.push(group); }
    $scope.select(group);
  };

  $scope.moveUp = function(group) {
    if (group.disabled) { return; }
    while ($scope.current !== group) { $scope.groups.pop(); }
    $scope.select(group);
  };

  $scope.isExpandable = function(group) {
    return !!group.children.length;
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

  initialize();
});
