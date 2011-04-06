/**
 * @author Li Junru
 */

//var locMarker;
//var currLoc = new google.maps.LatLng(0,0);
//var myLatlng = new google.maps.LatLng(-25.363882,131.044922);
var map;
var mapID = 'map_canvas';

function loadMap(){
    var myOptions = {
        zoom: 12,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        scaleControl: true,
	zoomControlOptions: {
		style: google.maps.ZoomControlStyle.LARGE,
        	position: google.maps.ControlPosition.LEFT_CENTER
	}
    };
    map = new google.maps.Map(document.getElementById(mapID), myOptions);
    //Determine current location
    var foundCurr = new Boolean(false);
    foundCurr = setCurrentLoc(map,true);
}    

// Similar to LoadMap, but does not find and center on current location
function loadMapWithoutCurrLoc(){
    var myOptions = {
        zoom: 12,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        scaleControl: true,
     	zoomControlOptions: {
                style: google.maps.ZoomControlStyle.LARGE,
                position: google.maps.ControlPosition.LEFT_CENTER
        }

    };
    map = new google.maps.Map(document.getElementById(mapID), myOptions);
}


function getLocation(fieldID, addressString){
  if (document.getElementById(fieldID).value != '') // If previously set 
  {
    loadMapWithoutCurrLoc();
    var temp = document.getElementById(fieldID).value.replace(/[()]/,'').split(",");
    map.setCenter( new google.maps.LatLng(parseFloat(temp[0]) , parseFloat(temp[1]))); 
    setMarkerCenter(fieldID);
  }
  else
  {
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode({ // Try to gecode coordinates from address
            address: addressString
        }, function(responses) {
            if (responses && responses.length > 0) {
                loadMapWithoutCurrLoc();
                map.setCenter(new google.maps.LatLng(responses[0].geometry.location.lat(), responses[0].geometry.location.lng()));
                setMarkerCenter(fieldID);
		document.getElementById(fieldID).value = map.getCenter().toString();
            } else {
                loadMap(); // If fail get current location
                setMarkerCenter(fieldID);
		map.getCenter().toString();
            }
        })
  }          
}

function setMarkerCenter(fieldID)
{
  locMarker = new google.maps.Marker({
      position: map.getCenter(),
      map: map
  });

  google.maps.event.addListener(map, 'click', function(event) {
    locMarker.setPosition(event.latLng);
    map.setCenter(event.latLng);
    document.getElementById(fieldID).value = event.latLng.toString();
  });
}


function placeMarker(marker_info) {
  var infoWin = new google.maps.InfoWindow();
  var f = function(map, marker, infoWin, contents){
                //prev_infoWin.close();
                //prev_infoWin = infoWin;
                return function(){
              infoWin.setContent(contents);
              infoWin.open(map, marker);
                }
         }

  for (i=0; i< marker_info.length ; i++)
  {
    var pos = new google.maps.LatLng(marker_info[i].lat, marker_info[i].lng);
    var marker = new google.maps.Marker({
        position: pos,
        map: map,
        title: marker_info[i].name
    });
    var contents = "<div style='text-align:center;color:black;'>" +marker_info[i].name + "<br/>" + marker_info[i].description + "<br/>" + marker_info[i].link + "</div>"; 
    google.maps.event.addListener(marker, 'click', f(map, marker, infoWin, contents));
   
  }
}




// String to LatLng
function toLatLng(location)
{
  var arr = location.spilt(",");
  return new google.maps.LatLng(-24.012344,131.122222);
  //parseFloat(arr[0]), parseFloat(arr[1]));
}


function setCurrentLoc(map, showMarker){
    var browserSupportFlag = new Boolean();
    var infoWin = new google.maps.InfoWindow({
        content: "<div style='text-align:center;color:black;'>You are here</div>"
    });
    var f = function(map, marker, infoWin){
        return function(){
            infoWin.open(map, marker);
        }
    }
    // Try W3C Geolocation method (Preferred)
    if (navigator.geolocation) {
        browserSupportFlag = true;
        navigator.geolocation.getCurrentPosition(function(position){
            currLoc = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            map.setCenter(currLoc);
            if (showMarker){
              marker = new google.maps.Marker({
                  position: currLoc,
                  map: map,
                  title: "You are here"
             });
              google.maps.event.addListener(marker, 'click', f(map, marker, infoWin));
            }
        }, function(){
            handleNoGeolocation(browserSupportFlag, map);
        });
    }
    else 
        if (google.gears) {
            // Try Google Gears Geolocation
            browserSupportFlag = true;
            var geo = google.gears.factory.create('beta.geolocation');
            geo.getCurrentPosition(function(position){
                currLoc = new google.maps.LatLng(position.latitude, position.longitude);
                map.setCenter(currLoc);
                if (showMarker){
                  marker = new google.maps.Marker({
                      position: currLoc,
                      map: map,
                      title: "You are here"
                  });
                  google.maps.event.addListener(marker, 'click', f(map, marker, infoWin));
                }
              }, function(){
                handleNoGeolocation(browserSupportFlag, map);
            });
        }
        else {
            // Browser doesn't support Geolocation
            browserSupportFlag = false;
            handleNoGeolocation(browserSupportFlag, map);
        }
		return browserSupportFlag;
}

function handleNoGeolocation(errorFlag, map){
	
}
