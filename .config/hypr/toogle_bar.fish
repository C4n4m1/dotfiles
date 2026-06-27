
set eww_state "opened"

if  [[ "$eww_state" == "opened" ]];  then 
  eww close bar
  eww_state="closed"
else
  eww open bar
  eww_state="opened"
fi
