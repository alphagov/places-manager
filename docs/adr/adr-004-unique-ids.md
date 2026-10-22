# Decision Record: Unique IDs

## Introduction

In October 2026, we began trialling maps based on places. In order
to support the map code we need a unique way of identifying a place
that can be shared between different representations (geojson, map
displays, html output, etc).

## Requirements

- We don't want this confusable with a content id
- It should be instantly recognisable
- It doesn't have to be cryptographically secure
- It should be unique for each service/data set version/place

## Decision

We'll base the IDs on a simple hexdigest of the source address and the data set version, prefixed with `place:` and the
name of the service followed by a dash (eg: `place:number-plate-supplier-f78008647a0c47fd7f21675c0fb2c30a`)

This is pretty cheap to compute, doesn't rely on database record ids, and can be tied back to a record simply.

## Resulting changes

- we will add a string uid to the tables for places and place archives
- the model will include a uniqueness constraint on the uid, and will automatically compute it on create.
- the uid will be exposed via the api, and visible in the user interface, but not editable
- the uid will not be present in KML/CSV/JSON outputs

