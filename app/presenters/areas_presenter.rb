class AreasPresenter

  def initialize(api_response)
    @status = api_response.code
    @areas = api_response.to_hash.values
  end

  def present
    {
      "_response_info" => {
        "status" => response_status,
        "links" => []
      },
      "total" => @areas.size,
      "start_index" => 1,
      "page_size" => @areas.size,
      "current_page" => 1,
      "pages" => 1,
      "results" => @areas.map { |a| area_attrs(a) }
    }
  end

  private

    def response_status
      if @status == 200
        "ok"
      else
        @status
      end
    end

    def area_attrs(area)
      {
        "id" => area["id"],
        "name" => area["name"],
        "country_name" => area["country_name"]
      }
    end

end
