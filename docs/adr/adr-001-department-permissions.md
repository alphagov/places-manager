# Decision Record: Department Permissions

## Introduction

In March 2024 a proposal was put to SteerCo to allow departments direct access
to Imminence to maintain their own data sets. Although all data in Imminence is
publicly available, we agreed with John-Paul Dickie (and previously with Alex
Pardoe) that it would make sense to restrict data set updating to the owning
department to avoid the risk of data sets being accidentally overwritten by
non-owner departments.

## Requirements

Each service would need to be owned by one or more departments. Only editors
with Imminence access permission in Signon should be allowed to view and edit
those services, with the usual caveat that selected GOV.UK staff should be
allowed to access all services for troubleshooting and incident response.

We looked at the way this was handled in Whitehall and other publishing apps,
where Signon provides the current user's organisational slug and access can
be limited based on that. A "GDS Editor" special permission is also typical
of these apps.

## Resulting changes

- Add an "organisational_slugs" field to each service, to be filled in by
  us for existing services before departments are given access. This will
  be a simple string field, with comma separation for multiple owners.
- Add a "GDS Editor" permission. Anyone with this permission can see and
  edit all services/data sets/places. Anyone without this permission can
  only access services whose organisational_slugs field contains the same
  slug as reported for them by Signon.
- When new services are made they will automatically be assigned an
  organisational_slug identical to the current user's, unless the user
  has the GDS Editor permission, in which case they will be able to edit
  the slug directly.

We will not at the moment add in an organisational drop-down, so any GDS
Editor making changes to the organisation slug will need to know the
correct one, but it is assumed that people with this permission will know
how to find that out.
