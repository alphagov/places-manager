require "gds_api/mapit"
require "plek"

Imminence.mapit_api = GdsApi::Mapit.new(Plek.new.find("mapit"))
