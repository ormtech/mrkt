require 'mrkt/version'
require 'mrkt/errors'

require 'mrkt/concerns/connection'
require 'mrkt/concerns/authentication'
require 'mrkt/concerns/crud_helpers'
require 'mrkt/concerns/crud_campaigns'
require 'mrkt/concerns/crud_leads'
require 'mrkt/concerns/crud_lists'
require 'mrkt/concerns/import_leads'
require 'mrkt/concerns/crud_custom_objects'
require 'mrkt/concerns/crud_programs'
require 'mrkt/concerns/crud_activities'
require 'mrkt/concerns/crud_opportunities'
require 'mrkt/concerns/crud_assets'
require 'mrkt/concerns/paging_tokens'
require 'mrkt/concerns/usage'

module Mrkt
  class Client
    include Connection
    include Authentication
    include CrudHelpers
    include CrudCampaigns
    include CrudLeads
    include CrudLists
    include ImportLeads
    include CrudCustomObjects
    include CrudPrograms
    include CrudActivities
    include CrudOpportunities
    include CrudAssets
    include PagingToken
    include Usage

    attr_accessor :debug

    def initialize(options = {})
      @host = options.fetch(:host)

      @client_id = options.fetch(:client_id)
      @client_secret = options.fetch(:client_secret)
      @partner_id = options.fetch(:partner_id, nil)
      @max_retries = options.fetch(:max_retries, 10)
      @connection = options.fetch(:connection, nil)

      @options = options
    end

    %i(get post delete).each do |http_method|
      define_method(http_method) do |path, payload = {}, &block|

        retries = 0
        begin
          authenticate!
          resp = connection.send(http_method, path, payload) do |req|
            add_authorization(req)
            block.call(req) unless block.nil?
          end
        rescue Mrkt::Errors::AccessTokenExpired, Mrkt::Errors::AuthorizationError
          if retries < @max_retries
            retries += 1
            sleep(3)
            retry
          else
            fail Mrkt::Errors::Error.new("Tried reauthentication #{@max_retries} times")
          end
        end

        resp.body
      end
    end
  end
end
