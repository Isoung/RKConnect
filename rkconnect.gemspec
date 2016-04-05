Gem::Specification.new do |s|
  s.name        = 'rkconnect'
  s.version     = '1.0.0.1'
  s.summary = 'Provides an interface to connect to a roku, send commands to the roku, and receive roku debugger messages.'
  s.date        = '2016-03-31'
  s.description = "An interface that connects to the roku."
  s.authors     = ["Isaiah Soung"]
  s.files       = [
  	"lib/rkconnect.rb", 
      "lib/thread_pool.rb",
  	"README.md"]
  s.license       = 'MIT'
end