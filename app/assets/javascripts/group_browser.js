/* global angular */
var peoplefinderApp = angular.module('peoplefinderApp', ['ngAnimate']);

peoplefinderApp.controller('GroupListCtrl', function($scope, $http) {
  $http.get('/org.json').success(function(tree) {
    $scope.selected = tree;
    $scope.groups = [tree];
  });

  $scope.moveDown = function(group) {
    $scope.groups.push(group);
    $scope.selected = group;
  };

  $scope.moveUp = function(group) {
    while ($scope.groups[$scope.groups.length - 1] !== group) {
      $scope.groups.pop();
    }
    $scope.selected = group;
  };
});
