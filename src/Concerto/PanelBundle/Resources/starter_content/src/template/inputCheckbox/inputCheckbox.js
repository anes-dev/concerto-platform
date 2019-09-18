testRunner.compileProvider.component('inputCheckbox', {
  templateUrl: testRunner.settings.directory + "ViewTemplate/inputCheckbox/content?css=1,html=1",
  bindings: {
    field: '=',
    values: '='
  },
  controller: function controller($scope) {
    this.$onInit = function() {
      $scope.field = this.field;
      $scope.values = this.values;
    };

    $scope.getValidator = function (type) {
      if (typeof this.field.validation === 'undefined') return null;
      for (var i = 0; i < this.field.validation.length; i++) {
        var validation = this.field.validation[i];
        if (validation.type === type) {
          return validation;
        }
      }
      return null;
    };

    if (typeof $scope.values[this.field.name] === 'undefined' || $scope.values[this.field.name] === "") {
      $scope.values[this.field.name] = 0;
    }
    testRunner.addExtraControl(this.field.name, function () {
      return $scope.values[$scope.field.name];
    });
  }
});
