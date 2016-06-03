module Mrkt
  module Usage
    def get_daily_usage
      get("/rest/v1/stats/usage.json")
    end

    def get_seven_day_usage
      get("/rest/v1/stats/usage/last7days.json")
    end
  end
end
