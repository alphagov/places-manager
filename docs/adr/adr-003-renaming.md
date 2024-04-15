# Decision Record: Renaming

## Introduction

In March 2024 a proposal was put to SteerCo to allow Departments direct access
to Imminence to maintain their own datasets. Most of the outcome of that is
mentioned in previous ADRs ([ADR-001-department-permissions](adr-001-department-permissions.md) and
[ADR-002-simplify-data-set-actions](adr-002-simplify-data-set-actions.md)),
but it also seemed like a good time to rename the app, since "Imminence" as
a name violates the [GDS naming guidelines](https://docs.publishing.service.gov.uk/manual/naming.html)

Since internally the smallest unit that Imminence deals with is the Place,
Places Manager seems like a reasonable name (Services and Data Sets, the larger
groups that Imminence deals with would result in too generic a name, and do
not describe what Imminence does). There's a small possibility that this will
cause confusion with Locations-API, but we believe this will be acceptably low.

### Resulting changes

We will
- Rename the app to Places Manager
- change the publishing url to replace imminence with places-manager
- rename any internal systems (k8s apps, etc) from imminence to places-manager
