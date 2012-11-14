//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$(document).ready(function() {
  $.each(["business_type", "location", "sector", "stage", "support_type"], function(idx, facet) {
    $("#business_support_" + facet + "_check_all").click(function(e) {
      $el = $(e.target);
      $.each($el.parent().parent().find(":checkbox"), function(sidx, chkbx) {
        $(chkbx).attr("checked", ($el.attr("checked")?true:false));
      });
    });
  });
});
