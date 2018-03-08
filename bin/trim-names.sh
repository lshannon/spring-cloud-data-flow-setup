#PCF has limit on the length of characters a route can be.
#As SCDF adds to the route name itself, the base should be smaller
trimname(){
  org=$1
  org_length=${#org}
  space=$2
  space_length=${#space}

  if [[ org_length > 5 ]]; then
    org=${org::4}
  fi

  if [[ space_length > 5 ]]; then
    space=${space::4}
  fi
  echo $org$space
}
