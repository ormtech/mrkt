module Mrkt
  module CrudActivities
    def browse_activity_types
      get("rest/v1/activities/types.json")
    end

    def get_deleted_leads(next_page_token:, batch_size: nil)
      params = {}

      params[:nextPageToken] = next_page_token
      params[:batchSize]     = batch_size if batch_size

      get("rest/v1/activities/deletedleads.json", params)
    end

    def get_activities(activity_type_ids, list_id: nil, next_page_token: nil, batch_size: nil, lead_ids: nil)
      params = {}
      ids = if activity_type_ids.is_a? Array
              activity_type_ids.join(",")
            elsif activity_type_ids.is_a? String
              activity_type_ids
            else
              raise ArgumentError.new("String or Array expected as first argument")
            end
      params[:activityTypeIds] = ids
      params[:nextPageToken] = next_page_token

      params[:listId] = list_id if list_id

      params[:batchSize] = batch_size if batch_size

      if lead_ids
        l_ids = if lead_ids.is_a? Array
                  lead_ids.join(",")
                elsif lead_ids.is_a? String
                  lead_ids
                else
                  raise ArgumentError.new("String or Array expected for Lead IDs")
                end
        params[:leadIds] = l_ids
      end

      get("/rest/v1/activities.json", params)
    end

    # Returns a CSV string of the activities
    def get_bulk_activities(activity_type_ids, date_range: nil, fields: nil)
      params = create_bulk_activities_params(activity_type_ids, date_range, fields)

      response  = create_job(params)
      export_id = response[:result][0][:exportId]

      response = enqueue_job(export_id)
      status   = response[:result][0][:status]

      while status != "Completed"
        sleep(60)
        response = check_job_status(export_id)
        status   = response[:result][0][:status]

        if ["Cancelled", "Failed"].include? status
          break
        end
      end

      if status == "Completed"
        file = Tempfile.new(export_id)

        file.write(retrieve_data(export_id).force_encoding("utf-8"))

        file.rewind

        file
      elsif status == "Failed"
        raise Mkto::Error::BulkActivitiesJobFailed
      elsif status == "Cancelled"
        raise Mkto::Error::BulkActivitiesJobCancelled
      end
    end

    def create_bulk_activities_params(activity_type_ids, date_range, fields)
      params = {}

      ids = if activity_type_ids.is_a? Array
              activity_type_ids.join(",")
            elsif activity_type_ids.is_a? String
              activity_type_ids
            else
              raise ArgumentError.new("String or Array expected as first argument")
            end
      params[:activityTypeIds] = ids

      start_at = date_range.begin.to_datetime.utc.iso8601
      end_at   = date_range.end.to_datetime.utc.iso8601
      params[:filter] = { createdAt: { startAt: start_at, endAt: end_at } }

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

    def create_job(params)
      post("/bulk/v1/activities/export/create.json") do |req|
        json_payload(req, params)
      end
    end

    def enqueue_job(export_id)
      post("/bulk/v1/activities/export/#{export_id}/enqueue.json")
    end

    def check_job_status(export_id)
      get("/bulk/v1/activities/export/#{export_id}/status.json")
    end

    def retrieve_data(export_id)
      get("/bulk/v1/activities/export/#{export_id}/file.json")
    end

    def cancel_job(export_id)
      post("/bulk/v1/activities/export/#{export_id}/cancel.json")
    end
  end
end
