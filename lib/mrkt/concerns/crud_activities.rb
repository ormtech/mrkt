module Mrkt
  module CrudActivities
    def browse_activity_types
      get("rest/v1/activities/types.json")
    end

    def get_activities(activity_type_ids, list_id: nil, next_page_token: nil, batch_size: nil)
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

      get("/rest/v1/activities.json", params)
    end
  end
end
