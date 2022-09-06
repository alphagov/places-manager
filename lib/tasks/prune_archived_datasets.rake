namespace :prune_archived_datasets do
  desc "Delete all archived DataSets apart from the most recent 3, and attached PlaceArchives"
  task go: [:environment] do
    prune_archived_datasets(dry_run: false)
  end

  task dry_run: [:environment] do
    prune_archived_datasets(dry_run: true)
  end
end

def prune_archived_datasets(dry_run: true)
  if dry_run
    puts("DRY RUN: NO DELETIONS WILL TAKE PLACE")
  else
    puts("LIVE RUN: RECORDS WILL BE DELETED")
  end

  Service.each do |service|
    archived_data_sets = service
      .data_sets
      .where(state: "archived")
      .asc(:version)

    archived_data_sets_count = archived_data_sets.count

    next unless archived_data_sets_count > 3

    deletable_data_set_versions = archived_data_sets
      .first(archived_data_sets_count - 3)
      .pluck(:version)

    puts("#{service.name}: #{deletable_data_set_versions.count} archived datasets to delete")

    deletable_place_archives = PlaceArchive.where(service_slug: service.slug)
                                           .in(data_set_version: deletable_data_set_versions)

    puts("#{service.name}: #{deletable_place_archives.count} place archives to delete")

    archived_data_sets.in(version: deletable_data_set_versions).delete_all unless dry_run
    deletable_place_archives.delete_all unless dry_run
  end
end
