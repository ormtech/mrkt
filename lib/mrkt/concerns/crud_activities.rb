module Mrkt
  module CrudActivities
    def browse_activity_types
      get("rest/v1/activities/types.json")
    end

    def get_activities(activity_type_ids, list_id: nil, next_page_token: nil, batch_size: nil)
      params = {}
      params[:activityTypeIds] = activity_type_ids

      params[:listId] = list_id if list_id

      params[:batchSize] = batch_size if batch_size
      params[:nextPageToken] = next_page_token if next_page_token

      get("/rest/v1/activities.json", params)
    end
  end
end
