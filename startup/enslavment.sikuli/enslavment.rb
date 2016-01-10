slave_name = ENV["COMPUTERNAME"]
puts "Connecting to " + slave_name + "..."
myApp = App.focus("C:\\Program Files\\Mozilla Firefox\\firefox.exe http://192.168.255.253:8080/login?from=/computer/" + slave_name)

sleep(5)

wait("1452356857512.png",5)

wait("1452356877025.png")
click("1452356895815.png")
paste("slave")
type(Key.TAB)

click("1452356911632.png")
paste("v3VFZnkkj0h1vCqx4Pz2")
click("1452356983179.png")


begin
    wait("1452358264990.png",5)
    click("1452358264990.png")
rescue
    wait("1452359089663.png")
    click("1452359089663.png")
    retry

end

begin
    wait("1452358359835.png",5)
    click("1452358382585.png")
rescue
end

begin
    wait("1452358526865.png",15) 
    connected = true
rescue
    connected = false
end

puts connected









