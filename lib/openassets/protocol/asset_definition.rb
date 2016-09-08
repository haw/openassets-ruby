require 'rest-client'
require 'httpclient'
module OpenAssets
  module Protocol

    # The Definition of Open Asset
    class AssetDefinition
      include OpenAssets::MethodFilter

      before_filter :clear_poa_cache, {:include => [:issuer=, :asset_definition_url=, :link_to_website=]}

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
      attr_accessor :proof_of_authenticity

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

      def include_asset_id?(asset_id)
        return false if asset_ids.nil? || asset_ids.empty?
        asset_ids.include?(asset_id)
      end

      # Convert Asset Definition to json format.
      def to_json
        h = to_hash
        h.delete('proof_of_authenticity')
        h.to_json
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
        if !asset_definition_url.nil? && link_to_website
          subject = ssl_certificate_subject
          return true if !subject.nil? && subject == issuer
        end
        result
      end

      def clear_poa_cache
        @proof_of_authenticity = nil
      end

      def ssl_certificate_subject
        cache = OpenAssets::Cache::SSLCertificateCache.new
        subject = cache.get(asset_definition_url)
        if subject.nil?
          response = HTTPClient.new.get(asset_definition_url, :follow_redirect => true)
          cert = response.peer_cert
          unless cert.nil?
            subjects = cert.subject.to_a
            o = subjects.find{|x|x[0] == 'O'}
            if !o.nil? && o.length > 2
              subject = o[1]
              cache.put(asset_definition_url, subject, cert.not_after)
            end
          end
        end
        subject
      end
    end

  end
end
