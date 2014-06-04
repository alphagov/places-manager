module MapitApi
  class ResponseBridge
    def initialize(response)
      @response = response
    end
    def payload
      @response.payload
    end
  end

  class AreasByTypeResponse
    def initialize(response)
      @response = response
    end
    def payload
      {
        :code => @response.code,
        :areas => @response.to_hash.values
      }
    end
  end

  class AreasByPostcodeResponse
    def initialize(location)
      @location = location
    end
    def payload
      # Invalid postcodes return a nil response
      if @location
        {
          :code => @location.response.code,
          :areas => @location.response.to_hash["areas"].values
        }
      else
        { :code => 404, :areas => [] }
      end
    end
  end
end
