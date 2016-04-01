require "net/http"
require 'net/telnet'
# require "socket"
require "uri"

# require_relative 'observer'
require_relative 'thread_pool'

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

		#Single threads could be used, though using a thread pool could provide future possibilites
		@thread_pool = ThreadPool.new(1)

		#Set an instance variable to block in order to use it elsewhere
		@callback = block

		@roku_debugger = Net::Telnet::new('Host' => @ip_address, 'Port' => DEBUGGER_PORT, 'Telnetmode' => false)

		#Use a threading to provide Telnet a thread to return data from the Roku debugger
		@thread_pool.schedule_jobs do 
			loop do
				@roku_debugger.cmd("TEST") do |c|
					if(c.size < 200)
						@callback.call(c)
					end
				end
			end
		end
	end 

	def press_remote(key)
		#Check to make sure the arg that is passed in is string else an error will be raised
		raise 'Invalid key type. Need a string arg' if !key.is_a? String

		Net::HTTP.post_form(URI(@http_address + EXTERNAL_C_PORT + "/keypress/#{key}"), {})
	end

	def return_channel_listing()
		return Net::HTTP.get(URI(@http_address + EXTERNAL_C_PORT + "/query/apps"))
	end

	def launch_channel(app_id)
		raise 'Invalid app_id type. Need a string arg' if !app_id.is_a? String

		Net::HTTP.post_form(URI(@http_address + EXTERNAL_C_PORT + "/launch/#{app_id}"), {})
	end

	private
		def ignore_exceptions
			begin
				yield
			rescue
				nil
			end
		end
end