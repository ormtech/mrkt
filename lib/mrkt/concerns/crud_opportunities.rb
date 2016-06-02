module Mrkt
  module CrudOpportunities
    def describe_opportunity
      get("/rest/v1/opportunities/describe.json")
    end

    def describe_company
      get("/rest/v1/companies/describe.json")
    end
  end
end

