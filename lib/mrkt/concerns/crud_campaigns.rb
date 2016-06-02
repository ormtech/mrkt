module Mrkt
  module CrudCampaigns
    def browse_campaigns(batch_size: nil, next_page_token: nil)
      params = {}
      params[:batchSize] = batch_size if batch_size
      params[:nextPageToken] = next_page_token if next_page_token

      get("/rest/v1/campaigns.json", params)
    end

    def request_campaign(id, lead_ids, tokens = {})
      post("/rest/v1/campaigns/#{id}/trigger.json") do |req|
        params = {
          input: {
            leads: map_lead_ids(lead_ids),
            tokens: tokens
          }
        }

        json_payload(req, params)
      end
    end
  end
end
