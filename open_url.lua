-- attempts to open a given url in the system default browser, regardless of operating system.
local open_cmd -- this needs to stay outside the function, or it'll re-sniff every time...
function _open_url(url)
 if not open_cmd then
     if package.config:sub(1,1) == '\\' then -- windows
         open_cmd = function(url)
             -- should work on anything since (and including) win'95
             os.execute(string.format('start "%s"', url))
         end
     -- the only systems left should understand uname...
     elseif (io.popen("uname -s"):read'*a') == "darwin" then -- osx/darwin ? (i can not test.)
         open_cmd = function(url)
             -- i cannot test, but this should work on modern macs.
             os.execute(string.format('open "%s"', url))
         end
     else -- that ought to only leave linux
         open_cmd = function(url)
             -- should work on x-based distros.
             os.execute(string.format('xdg-open "%s"', url))
         end
     end
 end

 open_cmd(url)
end
