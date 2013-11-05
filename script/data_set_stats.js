# This will show the size of data sets grouped by slug and version
db.places.group({
  key: { service_slug: 1 },
  reduce: function ( curr, result ) {
    var service = db.services.findOne({"slug": curr.service_slug});
    if (typeof(result['activeVersion']) == 'undefined') {
      result['activeVersion'] = service.active_data_set_version;
    }
    if (typeof(result['counts']) == 'undefined') {
      result['counts'] = [];
    }
    if (typeof(result.counts[curr.data_set_version]) == 'undefined') {
      result.counts[curr.data_set_version] = 0;
    }
    result.counts[curr.data_set_version] += 1;
  },
  initial: { }
  }
);
