module Mrkt
  module PagingToken
    def get_paging_token(since: nil)
      get("rest/v1/activities/pagingtoken.json", { sinceDatetime: since.strftime("%FT%T%:z") })
    end
  end
end
