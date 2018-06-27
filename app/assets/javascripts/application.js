//= require jquery
//= require bootstrap
//= require 'modules/form-value-dependent'


/**
 * Activate the tab specified by the location hash
 */
$(document).ready(function () {
  var $tabToActivate = $('.nav-tabs a[href="' + window.location.hash + '"]');
  if ($tabToActivate.length) {
    $tabToActivate.tab('show');
  }
});
