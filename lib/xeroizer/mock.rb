module Xeroizer
	class Mock

		# This class is used to mock fake responses from xero and handle response codes 200, 400, 401, 404, and 503
		# To get fake error response either id of query need to end with respective error code or specified message need to be included in 
		# any of post or put requeset body
		# Error files are placed in mock_files directory

		ERROR_RESPONSE_DETERMINER = {
			auth: 
			{ 
				message: 'Unauthorized', 
				code: 401
			},
			bad: 
			{
				message: 'Bad Request',
				code: 400
			},
			not_found: 
			{ 
				message: 'Not Found', 
				code: 404
			},
			limit:
			{
				message: 'Rate Limit Exceeded',
				code: 503
			}
		}

		def initialize(request_method, request_uri, headers , raw_body = nil)
			@method = request_method
			@uri = request_uri
			@headers = headers
			@body = raw_body
			get_type_and_id
		end

		def mock_response
			#TODO:Handle Response according to request parameters
			# logger.info("*****************Mock Xero API**********************") 
			# logger.info("METHOD ::::::::  #{@method}")
			# logger.info("URI ::::::::  #{@uri}")
			# logger.info("HEADERS ::::::::  #{@headers}")
			# logger.info("BODY ::::::::  #{@body}")
			# logger.info("*****************Mock Xero API Params**********************")
			resp_type = response_type
			resp_code = !resp_type.blank? ? ERROR_RESPONSE_DETERMINER[resp_type][:code] : 200
			generate_response(mock_file_path(resp_type), resp_code)
		end

		private 
		def mock_file_path(resp_type)
			# logger.info("Response Type:::::: #{resp_type}") 
			if resp_type && !resp_type.eql?(:bad)
				path = File.join(File.expand_path('../../',__FILE__),'mock_files', add_xml_extension(resp_type))
			else
				path = File.join(File.expand_path('../../',__FILE__),'mock_files', @type.to_s, @method.to_s,  response_file_name)
			end
			# logger.info("Response file Path:::::: #{path}")
			raise "Mock for this request is not available." unless File.exist?(path)
			path
		end

		def get_type_and_id
			base_url = Xeroizer.api_config[:xero_url].split(Xeroizer.api_config[:site])[1]
			xero_query =  @uri.split(base_url)[1].last(-1) # Remove first character /
			@type = xero_query.split('/')[0].downcase unless xero_query.split('/')[0].blank?
			@data_id = xero_query.split('/')[1].downcase unless xero_query.split('/')[1].blank?
		end

		def generate_response(path, status_code)
			OpenStruct.new(:plain_body => File.read(path), :code => status_code)
		end

		def response_file_name
			name ="#{@type}"
			name.concat("_" + response_type.to_s) unless response_type.blank?
			name.concat('_').concat(@data_id) unless @data_id.blank?
			name = add_xml_extension(name)
			# logger.info("Response file Name:::::: #{name}")
			name
		end

		def add_xml_extension(file)
			file.to_s.concat('.xml')
		end

		def response_type
			error_message = ERROR_RESPONSE_DETERMINER.values.select { |word| @body[:xml].to_s.include?(word[:message]) ||  (@data_id && @data_id.end_with?(word[:code]))}
			error_message.any? ?  ERROR_RESPONSE_DETERMINER.key(error_message[0]) : nil
		end
	end
end