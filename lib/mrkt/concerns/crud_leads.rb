module Mrkt
  module CrudLeads
    def describe_leads
      get("/rest/v1/leads/describe.json")
    end

    def get_leads(filter_type, filter_values, fields: nil, batch_size: nil, next_page_token: nil)
      params = {
        filterType: filter_type,
        filterValues: filter_values.join(',')
      }
      params[:fields] = fields if fields
      params[:batchSize] = batch_size if batch_size
      params[:nextPageToken] = next_page_token if next_page_token

      get('/rest/v1/leads.json', params)
    end

    def get_lead_changes(fields: nil, batch_size: nil, list_id: nil, next_page_token: nil)
      params = {
        fields:           fields,
        next_page_token:  next_page_token
      }
      params[:batch_size] if batch_size
      params[:list_id] if list_id

      get('/rest/v1/activities/leadchanges.json', params)
    end

    def createupdate_leads(leads, action: 'createOrUpdate', lookup_field: nil, partition_name: nil, async_processing: nil)
      post('/rest/v1/leads.json') do |req|
        params = {
          action: action,
          input: leads
        }
        params[:lookupField] = lookup_field if lookup_field
        params[:partitionName] = partition_name if partition_name
        params[:asyncProcessing] = async_processing if async_processing

        json_payload(req, params)
      end
    end

    def delete_leads(leads)
      delete('/rest/v1/leads.json') do |req|
        json_payload(req, input: map_lead_ids(leads))
      end
    end

    def associate_lead(id, cookie)
      params = Faraday::Utils::ParamsHash.new
      params[:cookie] = cookie

      post("/rest/v1/leads/#{id}/associate.json?#{params.to_query}") do |req|
        json_payload(req, {})
      end
    end
  end
end
