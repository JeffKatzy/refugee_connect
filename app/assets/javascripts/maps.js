function display_map(lat, long)
{
  var mapOptions = {
    center: new google.maps.LatLng(lat, long),
    zoom: 13,
    mapTypeId: google.maps.MapTypeId.SATELLITE
  };
 
  canvas = $('#map_canvas')[0];
  map = new google.maps.Map(canvas, mapOptions);
}
 
function add_marker(lat, long, title)
{
  var latlng = new google.maps.LatLng(lat, long);
  var marker = new google.maps.Marker({position: latlng, map: map, title: title});
}

