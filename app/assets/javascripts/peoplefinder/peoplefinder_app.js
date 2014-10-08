/* global angular, document */
//= require angular
//= require angular-animate/angular-animate

var peoplefinderApp = angular.module('peoplefinderApp', ['ngAnimate']);

peoplefinderApp.injectNewContainer = function(container) {
  angular.element(document).injector().invoke(function ($compile) {
    var scope = angular.element(container).scope();
    $compile(container)(scope);
  }, this);
};
