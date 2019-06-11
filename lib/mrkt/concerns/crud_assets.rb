module Mrkt
  module CrudAssets
    def get_emails_for_program(program_id, max_return: 200, offset: nil)
      params = {
        :maxReturn => max_return,
        :folder    => %Q({"id":#{ program_id },"type":"Program"})
      }
      params[:offset] = offset if offset

      get("/rest/asset/v1/emails.json", params)
    end

    def get_files(id, max_return: 200, offset: nil)
      params = {
        maxReturn: max_return,
        folder:    %Q({"id":#{id},"type":"Folder"})
      }

      params[:offset] = offset if offset

      get("/rest/asset/v1/files.json", params)
    end
  end
end
