class ThreadPool
	def initialize(size)
		@size = size
		@job_queue = Queue.new

		@pool = Array.new(@size) do |i|
			Thread.new do
				Thread.current[:id] = i

				catch(:exit) do
					loop do 
						job, args = @job_queue.pop
						job.call(*args)
					end
				end
			end
		end
	end

	def schedule_jobs(*args, &block)
		@job_queue << [block, args]
	end

	def kill()
		@size.times do
			schedule_jobs{throw :exit}
		end

		@pool.map(&:join)
	end
end