# ----------------------------------------------------------------------
# 	Executed at slave startup to connect them to Jenkins master
#	Author : orion1024
# 	Date : 2016
# ----------------------------------------------------------------------

require 'sikulix'
include Sikulix

# Some methods that enhance sikuliX scripts
require_relative '../common/sikulix'

#######		Start of script		#########

connected = false

# Fetching JENKINS information from the environment variables
slave_name = ENV["SLAVE_NAME"]
jenkins_host = ENV["JENKINS_HOST"]
jenkins_user = ENV["JENKINS_USER"]
jenkins_password = ENV["JENKINS_PASSWORD"]


puts "Connecting to " + slave_name + "..."
myApp = App.focus("C:\\Program Files\\Mozilla Firefox\\firefox.exe http://" + jenkins_host + ":8080/login?from=/computer/" + slave_name)

puts "Waiting for firefox to load..."
smartWait("Jenkins_Logo.png", 30)

browserRegion = App.focusedWindow()

puts "Looking for login form..."
if browserRegion.nil?
	loginFormRegion = smartWait("Jenkins_LoginForm.png", 120)
else
	loginFormRegion = smartWait("Jenkins_LoginForm.png", 120, browserRegion)
end

if loginFormRegion.nil?
	puts "Couldn't find login form."
else

	puts "Now filling in login form..."
	
	if smartWaitAndClick("Jenkins_UserField.png", 2, loginFormRegion) != 1
		puts "Couldn't find the login field."
	else
	
		# to prevent any autofill from screwing up the paste
		sleep(2)
		
		paste(jenkins_user)
		type(Key.TAB)
		
		# to prevent any autofill from screwing up the paste
		sleep(1)
		
		paste(jenkins_password)
		
		if smartWaitAndClick("Jenkins_LogInButton.png", 2, loginFormRegion) != 1
			puts "Couldn't find the login button."
		else

			puts "Login form completed. Now looking for Jenkins Java Web Start button..."

			sleep(5)
			
			javaWebStartButtonFound = 0
			retries = 0
			while javaWebStartButtonFound != 1 and retries < 10
			
				# Sometimes the button is located at the very bottom of the page, getting there.
				type(Key.END)
				sleep(2)
				
				# Looking for the button.
				javaWebStartButtonFound = smartWaitAndClick("Jenkins_JavaWebLaunchButton.png", 5, browserRegion)
				
				# Not found ? let's try disconnecting the slave manually. Sometimes Kenkins thinks slave is still connected and so hides the button.
				if javaWebStartButtonFound != 1
					retries = retries + 1
					puts "Jenkins Java Web Start button not found. trying to bring it back, retry #%d" % retries
					
					# Disconnect button is on top of the page, so we go up.
					type(Key.HOME)
					sleep(2)
					
					# launching the disconnect action using the URL, it's better than using image recognition.
					smartWaitAndClick("Jenkins_DisconnectButton.png", 2, browserRegion)
					
					sleep(1)
					
					# jenkins asks for confirmation
					smartWaitAndClick("Jenkins_ConfirmDisconnectZone.png", 2, browserRegion, "Jenkins_ConfirmDisconnectButton.png", true)
					sleep(1)
				end		
			end
			
			if javaWebStartButtonFound == 1
			
				# We now wait for the connected image to appear.
				# But since Java is so annoying, we might have security prompts/warnings that we might need to clear before it consents to run the applet...
				# So we look for the connected image, but if it doesn't appear after a while we also check for such prompts.
				retries = 0
				while not connected and retries < 5
				
					connectedMatch = smartWait("Jenkins_Connected.png", 4)
					connected = not(connectedMatch.nil?)
					
					if not connected
						retries = retries + 1
						# No connected image ? there might be some prompt asking us something
						if smartWaitAndClick("Java_RunThisApplicationDialog.png", 1, browserRegion, "Java_RunThisApplicationRunButton.png", true) == 1
							puts "Found a Run this application dialog."
						end
						if smartWaitAndClick("Java_UpdateNeededDialog.png", 1, browserRegion, "Java_UpdateNeededDialog_LaterButton.png", true) == 1
							puts "Found a Java update dialog."
						end
					end
				end
				
				if not connected
					puts "Couldn't find jenkins connected image."
				end
			else
				puts "Couldn't find Jenkins Java Web Start button."
			end
		end
	end
end

if connected
	puts "Connected successfully to jenkins as slave " + slave_name + "."
else
	puts "Failed to connect to Jenkins."
end









