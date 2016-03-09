(function(Modules) {
  "use strict";

  Modules.FormValueDependent = function() {
    var that = this;

    that.start = function(element) {
      var controlElem = $('#'+element.data('form-value-dependent-elem'));
      if (controlElem.length > 0) {
        var controlValue = element.data('form-value-dependent-value'),
          controlled = element,
          toggleControlled = function() {
            if (controlElem.val() === controlValue) {
              controlled.show();
            } else {
              controlled.hide();
            };
          };

        controlElem.on('change', toggleControlled);
        toggleControlled();
      };
    };
  };

})(window.GOVUKAdmin.Modules);
