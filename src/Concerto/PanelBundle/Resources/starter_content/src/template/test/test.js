testRunner.controllerProvider.register("test", function ($scope) {
  $scope.items = testRunner.R.items;
  $scope.canGoBack = testRunner.R.canGoBack == 1;
  $scope.responseRequired = testRunner.R.responseRequired == 1;
  $scope.responseRequiredAlert = testRunner.R.responeRequiredAlert;
  $scope.page = testRunner.R.page;
  $scope.totalPages = testRunner.R.totalPages;
  $scope.pastResponses = testRunner.R.responses;
  $scope.responses = {};

  if ($scope.pastResponses) {
    for (var i = 0; i < $scope.pastResponses.length; i++) {
      var response = $scope.pastResponses[i];
      $scope.responses["r" + response.item_id] = typeof response.response === 'object' ? response.response : {value: response.response};
    }
  }

  for (var i = 0; i < $scope.items.length; i++) {
    var item = $scope.items[i];
    if (typeof item.responseOptions === "string") {
      item.responseOptions = JSON.parse(item.responseOptions);
      $scope.items[i] = item;
    }
    $scope.items[i] = item;

    if (typeof $scope.responses["r" + item.id] === 'undefined') {
      $scope.responses["r" + item.id] = {};
    }
  }
});
