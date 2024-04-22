# Adding a new service

Adding a new service in Places Manager is fairly straightforward and comprises of
two main parts:

1) The **service** which is [created in Places Manager]. We need to provide the slug
(this isn't the slug for the live www.gov.uk URL, rather the endpoint the
service landing page will use internally to fetch the relevant locations), name
and a CSV containing all the locations that provide the new service. Guidance
around the CSV data can be found on the service creation page.

2) The **service landing page** (Artefact) which is [created in Publisher]. The
Publisher format type for a new service is 'Place'. To link the Artefact
created in Publisher to the service in Places Manager, the field "This is the 'slug'
assigned in the places manager app" needs to be populated with the internal slug
created in step 1. Once the Artefact is published, the service should be up and
running.

[created in Places Manager]: https://places-manager.integration.publishing.service.gov.uk/admin/services/new
[created in Publisher]: https://publisher.integration.publishing.service.gov.uk/artefacts/new
