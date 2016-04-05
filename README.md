# RKConnect (Roku Connect)
######Provides an interface to connect to a roku, send commands to the roku, and receive roku debugger messages.'

## Usage
1. 'gem install rkconnect'
2. rkc = RKConnect(ip_address_of_roku, &callback_block)
3. rkc.post_key("Right")     <-- Presses the right button on "roku remote"
4. rkc.post_channel('dev')   <-- Launches 'dev' application from home screen
5. rkc.request_debug('var')  <-- Returns all variables currently located on screen


## Roku External Controller DOCS
(https://sdkdocs.roku.com/display/sdkdoc/External+Control+Guide)

## Roku Debugger Commands
(https://sdkdocs.roku.com/display/sdkdoc/Debugging+Your+Application)
