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

    def get_leads_by_program(program_id, batch_size: nil, next_page_token: nil, fields: nil)
      params = {}
      params[:fields] = fields if fields
      params[:batchSize] = batch_size if batch_size
      params[:nextPageToken] = next_page_token if next_page_token

      get("/rest/v1/leads/program/#{program_id}.json", params)
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


    # Returns a CSV string of the activities
    def get_bulk_leads(updated_date_range: nil, fields: nil)
      params = create_bulk_leads_params(updated_date_range, fields)

      response  = create_lead_job(params)
      export_id = response[:result][0][:exportId]

      response = enqueue_lead_job(export_id)
      status   = response[:result][0][:status]

      while status != "Completed"
        sleep(60)
        response = check_lead_job_status(export_id)
        status   = response[:result][0][:status]

        if ["Cancelled", "Failed"].include? status
          break
        end
      end

      if status == "Completed"
        file = Tempfile.new(export_id)

        file.write(retrieve_lead_data(export_id).force_encoding("utf-8"))

        file.rewind

        file
      elsif status == "Failed"
        raise Mkto::Error::BulkLeadsJobFailed
      elsif status == "Cancelled"
        raise Mkto::Error::BulkLeadsJobCancelled
      end
    end

    def create_bulk_leads_params(date_range, fields)
      params = {}
      start_at = date_range.begin.to_datetime.utc.iso8601
      end_at   = date_range.end.to_datetime.utc.iso8601
      params[:filter] = { updatedAt: { startAt: start_at, endAt: end_at } }

      if fields
        field_names = if fields.is_a? Array
                        fields.join(",")
                      elsif fields.is_a? String
                        fields
                      else
                        raise ArgumentError.new("String or Array expected for field names")
                      end
        params[:fields] = field_names
      end

      params
    end

    def create_lead_job(params)
      post("/bulk/v1/leads/export/create.json") do |req|
        json_payload(req, params)
      end
    end

    def enqueue_lead_job(export_id)
      post("/bulk/v1/leads/export/#{export_id}/enqueue.json")
    end

    def check_job_lead_status(export_id)
      get("/bulk/v1/leads/export/#{export_id}/status.json")
    end

    def retrieve_lead_data(export_id)
      get("/bulk/v1/leads/export/#{export_id}/file.json")
    end

    def cancel_lead_job(export_id)
      post("/bulk/v1/leads/export/#{export_id}/cancel.json")
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
