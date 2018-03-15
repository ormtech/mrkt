module Mrkt
  module Usage
    def get_daily_usage
      get("/rest/v1/stats/usage.json")
    end

    def get_seven_day_usage
      get("/rest/v1/stats/usage/last7days.json")
    end

    def get_partitions
      get("/rest/v1/leads/partitions.json")
    end
  end
end
