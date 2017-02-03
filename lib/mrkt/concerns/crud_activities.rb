module Mrkt
  module CrudActivities
    def browse_activity_types
      get("rest/v1/activities/types.json")
    end

    def get_deleted_leads(next_page_token: nil)
      params = {}
      params[:nextPageToken] = next_page_token

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
  end
end
