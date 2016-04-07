require "net/http"
require 'net/telnet'
require "uri"

class RKConnect
	# include Observer
	DEBUGGER_PORT = '8085'
	EXTERNAL_C_PORT = '8060'

	def initialize(ip_address, &block)
		#Check to make sure that the ip address used to initialize is valid
		raise 'Invalid ip_address type. Need a string arg' if !ip_address.is_a? String
		raise 'Invalid ip_address.' if ip_address.split('.').size != 4
		raise 'No callback block was passed in. Make sure a block is passed in as an argument.' if block == nil

		#Set two different ip addresses. One is just the ip address and the other 'http' is used to send commands to the roku
		@ip_address = ip_address
		@http_address = 'http://' << ip_address << ':'\

		@callback = block

		@roku_debugger = Net::Telnet::new('Host' => @ip_address, 'Port' => DEBUGGER_PORT, 'Telnetmode' => false, 'Waittime' => 0.5)
	end 

	def post_key(key)
		raise 'Invalid key type. Need a string arg' if !key.is_a? String

		Net::HTTP.post_form(URI(@http_address + EXTERNAL_C_PORT + "/keypress/#{key}"), {})  
		sleep 0.25
	end

	def post_channel(app_id)
		#Launch a channel based on the application id. Should be only be used in the home screen.
		raise 'Invalid app_id type. Need a string arg' if !app_id.is_a? String

		Net::HTTP.post_form(URI(@http_address + EXTERNAL_C_PORT + "/launch/#{app_id}"), {})
		sleep 0.25
	end

	def request_channel_listing()
		#Returns a http response in xml format
		return Net::HTTP.get(URI(@http_address + EXTERNAL_C_PORT + "/query/apps"))
	end

	def request_debug(request)
		raise 'Invalid request type. Need a string arg' if !request.is_a? String

		callback_string = ' '
		#Breaks the telnet connection and enters the roku debugger.
		ignore_exceptions{@roku_debugger.cmd("String" => "\03", "Timeout" => 0.1)}

		@roku_debugger.cmd(request) do | telnet_callback |
			callback_string << telnet_callback
		end

		callback_string.sub!("BrightScript Debugger>", "")
		array = callback_string.split(/\n/)

		@callback.call(callback_string)

		ignore_exceptions{@roku_debugger.cmd("String" => "cont", "Timeout" => 0.1)}
	end

	def close_connection
		@roku_debugger.close
	end

	private
		def ignore_exceptions
			begin
				yield
			rescue Exception => e
				# puts(e.message)
			end
		end
end