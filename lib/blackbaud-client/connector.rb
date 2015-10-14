module Blackbaud
  class Connector
    attr_accessor(:token, :web_services_url, :save_request_data_to)
    def initialize(url, save_request_data_to)
      @web_services_url = url
      @save_request_data_to = save_request_data_to
    end

    def get(endpoint, filters=nil)
      query_strings = {
        'page' => 1,
        'perpage' => 100
      }
      url = construct_url(@web_services_url, endpoint, filters, query_strings)
      p url
      response = RestClient.get(url)
      write_json_to_file(url, json) if @save_request_data_to
      JSON.parse(response)
    end

    def post(endpoint, body)
      url = construct_url(@web_services_url, endpoint)
      response = RestClient.post(url, body, {:content_type=>'application/json'})
      JSON.parse(response)
    end

    def construct_url(web_services_url, endpoint, filters=nil, query_strings={})
      params = "?token=#{@token}" if @token
      if filters
        filters = Array(filters).map do |k,v|
          v = Array(v)
          "(#{k}%20eq%20#{v.join(',')})" if v && !v.join.empty?
        end
        params << "&filter=#{filters.join}"
      end
      query_strings.each do |k, v|
        params << "&#{k}=#{v}"
      end    
      url = "#{web_services_url}/#{endpoint}#{params}"
    end

    def write_json_to_file(url, data)
      return unless data
      file = url.gsub( /\/|\\/, ':' ).match(/.{,250}$/).to_s + '.json'
      file = File.expand_path(File.join(@save_request_data_to, file))
      FileUtils.mkdir_p @save_request_data_to
      File.open(file, 'w') { |f| f.write(JSON.pretty_unparse(JSON.parse(data)))}
    end
  end
end
