//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$(document).ready(function() {
  $.each(["business_type", "location", "sector", "stage", "support_type"], function(idx, facet) {
    $("#business_support_" + facet + "_check_all").click(function(e) {
      var $el = $(e.target);
      $.each($el.parent().parent().find(":checkbox"), function(sidx, chkbx) {
        $(chkbx).attr("checked", ($el.attr("checked")?true:false));
      });
    });
  });

  /*
   * Checks all child regions when a country is checked.
   */
  var countryRE = /^England|Northern Ireland|Scotland|Wales$/
  var country = $('label').filter(function () { return $(this).text().trim().match(countryRE); });
  country.children(":checkbox").click(function(e) {
    var $el = $(e.target);
    $.each($el.parent().parent().find(":checkbox"), function(sidx, chkbx) {
      var labelText = $(chkbx).parent().text().trim();
      if (labelText == country || (!labelText.match(countryRE) && labelText != "All")) {
        $(chkbx).attr("checked", ($el.attr("checked")?true:false));
      }
    });
  });
});
