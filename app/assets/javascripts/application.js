//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$(document).ready(function() {
  $.each(["business_type", "location", "purpose", "sector", "stage", "support_type"], function(idx, facet) {
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
  var allLabels = $('#location').find('label');
  var countries = allLabels.filter(function () { 
    return $(this).text().trim().match(/^England|Northern Ireland|Scotland|Wales$/);
  });

  countries.each (function (index, country) {
    $(country).children(":checkbox").on("click", function () {
      var countryLabel = $(country).text().trim();
      var matches = allLabels.filter(function() {
        var matchText = $(this).text().trim();
        return matchText.indexOf(countryLabel) > -1 && matchText != countryLabel;
      });
      matches.each (function (index, match) {
        var checkbox = $(match).children(":checkbox");
        checkbox.attr("checked", !checkbox.attr("checked"));
      });
    });
  });
});
