class AreasPresenter
  def initialize(response_bridge)
    @status = response_bridge.payload[:code]
    @areas = response_bridge.payload[:areas]
  end

  def present
    {
      "_response_info" => {
        "status" => response_status,
        "links" => [],
      },
      "total" => @areas.size,
      "start_index" => 1,
      "page_size" => @areas.size,
      "current_page" => 1,
      "pages" => 1,
      "results" => @areas.map { |a| area_attrs(a) },
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
      "name" => area["name"],
      "country_name" => area["country_name"],
      "type" => area["type"],
      "codes" => {
        "gss" => area.fetch("codes", {})["gss"],
      },
    }
  end
end
