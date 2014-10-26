
root = exports ? this

home =[47.67645, -122.39607]
map = null
circle = null

click = (e) ->
  circle.setLatLng(e.latlng)
  console.log(e.latlng)

currentLocation = () ->
  circle.getLatLng()

populateModal = (latlon) ->
  d3.select("#formLat").attr("value", latlon.lat)
  $("#formLat").val(latlon.lat)
  d3.select("#formLon").attr("value", latlon.lng)
  d3.select("#formType").attr("value", "tree")

save = () ->
  values = $("#newForm").serializeArray()
  console.log(values)
  $('#myModal').modal('hide')

  d3.event.preventDefault()


make = () ->
  loc = currentLocation()
  console.log(loc)
  populateModal(loc)
  $('#myModal').modal()
  d3.select("#newForm").on("submit", save)
  d3.event.stopPropagation()

initMap = () ->
  map = L.map('map').setView(home, 18)
  

  L.tileLayer('http://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
    maxZoom: 22
  }).addTo(map)


initCircle = () ->
  circle = L.circle([51.508, -0.11], 5, {
    color: 'red',
    fillColor: '#f03',
    fillOpacity: 0.5
  })

  circle.setLatLng(home)
  circle.addTo(map)


$ ->

  initMap()
  initCircle()

  map.on('click', click)
  d3.select("#create").on('click', make)
  

