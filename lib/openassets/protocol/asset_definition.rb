require 'rest-client'
require 'httpclient'
module OpenAssets
  module Protocol

    # The Definition of Open Asset
    class AssetDefinition

      attr_accessor :asset_definition_url

      attr_accessor :asset_ids
      attr_accessor :name_short
      attr_accessor :name
      attr_accessor :contract_url
      attr_accessor :issuer
      attr_accessor :description
      attr_accessor :description_mime
      attr_accessor :type
      attr_accessor :divisibility
      attr_accessor :link_to_website
      attr_accessor :icon_url
      attr_accessor :image_url
      attr_accessor :version

      def initialize
        @asset_ids = []
        @version = '1.0'
        @divisibility = 0
      end

      # Parse the JSON obtained from the json String, and create a AssetDefinition object.
      # @param[String]
      def self.parse_json(json)
        parsed_json = JSON.parse(json)
        definition = new
        definition.asset_ids = parsed_json['asset_ids']
        definition.name_short = parsed_json['name_short']
        definition.name = parsed_json['name']
        definition.contract_url = parsed_json['contract_url']
        definition.issuer = parsed_json['issuer']
        definition.description = parsed_json['description']
        definition.description_mime = parsed_json['description_mime']
        definition.type = parsed_json['type']
        definition.divisibility = parsed_json['divisibility']
        definition.link_to_website = parsed_json['link_to_website']
        definition.icon_url = parsed_json['icon_url']
        definition.image_url = parsed_json['image_url']
        definition.version = parsed_json['version']
        definition
      end

      # Parse the JSON obtained from the URL, and create a AssetDefinition object.
      # @param[String] url The URL of Asset Definition.
      def self.parse_url(url)
        begin
          definition = parse_json(RestClient.get url, :accept => :json)
          definition.asset_definition_url = url
          definition
        rescue => e
          puts e
          nil
        end
      end

      def include_asset_id?(asset_id)
        return false if asset_ids.nil? || asset_ids.empty?
        asset_ids.include?(asset_id)
      end

      # Convert Asset Definition to json format.
      def to_json
        to_hash.to_json
      end

      def to_hash
        instance_variables.inject({}) do |result, var|
          key = var.to_s
          key.slice!(0) if key.start_with?('@')
          result.update(key => instance_variable_get(var))
        end
      end

      # Check Proof of authenticity.
      # SSL certificate subject matches issuer.
      def proof_of_authenticity
        @proof_of_authenticity ||= calc_proof_of_authenticity
      end

      private
      def calc_proof_of_authenticity
        result = false
        unless asset_definition_url.nil?
          client = HTTPClient.new
          response = client.get(asset_definition_url, :follow_redirect => true)
          cert = response.peer_cert
          unless cert.nil?
            subject = response.peer_cert.subject.to_a
            o = subject.find{|x|x[0] == 'O'}
            result = true if !o.nil? && o.length > 2 && o[1] == issuer
          end
        end
        result
      end
    end

  end
end
