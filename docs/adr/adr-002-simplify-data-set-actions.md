# Decision Record: Simplifying Data Set Actions

## Introduction

In March 2024 a proposal was put to SteerCo to allow Departments direct access
to Imminence to maintain their own data sets. Most of the outcome of that is
mentioned in another ADR ([ADR-001-department-permissions](adr-001-department-permissions.md)),
but it also made sense to improve the user interface by updating it to use
the Government Design System and removing some options which had not been used
in practice.

Imminence works on a hierarchy of data in which a service contains multiple
data sets, which in turn contain multiple places. In the old admin interface,
there was a feature to duplicate existing data sets and then directly edit the
places in those data sets before the new data set was made active.

On consultation with the current users, though, it was found that these features
were never used - the typical work cycle in Imminence is to download the current
data set as a CSV (if you don't already have it), edit the CSV, and then upload
it as a new data set. Error fixing is done at the file level rather than by
directly editing places.

### Resulting changes

With this in mind, we can simplify both the UI and the codebase by removing
the duplicate facility and the facility to edit places directly.

We will
- Update the design from the old govuk_admin_template/bootstrap design to
  one based on the Government Design System (using the
  govuk_publishing_components gem)
- Remove the duplicate data set functionality from the Data Set Controller.
- Remove the edit action / views from the Places Controller.
- Add a show action / view to the Places Controller so that place information
  can be viewed (previously the only way of doing this was thorugh the edit
  action)
- Allow the Data Set places list to be filtered to easily identify broken
  records that can then be fixed at the CSV level.
