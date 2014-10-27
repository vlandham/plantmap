
root = exports ? this

home =[47.67645, -122.39607]
map = null
current = null
position = null

locRef = null

table_url = "https://docs.google.com/spreadsheets/d/1Y_rBIlUwBYWDAz0Hp_SooQnESTbfhIZE-r5fGMRTbEA/pubhtml"
allTypes = null

allLocs = null

click = (e) ->
  current.setLatLng(e.latlng)

currentLocation = () ->
  current.getLatLng()

populateModal = (latlon) ->
  d3.select("#formLat").attr("value", latlon.lat)
  d3.select("#formLon").attr("value", latlon.lng)
  # d3.select("#formType").attr("value", "tree")

saveData = (newData) ->
  locRef.push(newData)

isFloatData = (name) ->
  rtn = false
  if name == "lat"
    rtn = true
  if name == "lon"
    rtn = true
  rtn

setupData = (values) ->
  data = {}
  values.forEach (v) ->
    name = v.name.replace("form","").toLowerCase()
    value = if (isFloatData(name)) then +v.value else v.value
    data[name] = value
  data

  
save = () ->
  values = $("#newForm").serializeArray()
  data = setupData(values)
  saveData(data)
  $('#myModal').modal('hide')

  d3.event.preventDefault()


make = () ->
  loc = currentLocation()
  populateModal(loc)
  $('#myModal').modal()
  d3.select("#newForm").on("submit", save)
  types = allTypes.map((d) -> d.type)
  $("#formType").typeahead({ source:types})
  d3.event.stopPropagation()

initMap = () ->
  map = L.map('map').setView(home, 18)
  
  L.tileLayer('http://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
    maxZoom: 20
  }).addTo(map)


initCurrent = () ->
  icon = L.MakiMarkers.icon({icon: "rocket", color: "#b0b", size: "m"})
  current = L.marker(home,{icon: icon})

  current.setLatLng(home)
  current.addTo(map)

initTypes = (data, tabletop) ->
  allTypes = data

showCurrent = (snapshot) ->
  val = snapshot.val()
  d3.map(val).values().forEach (d) ->
    pos = [d.lat, d.lon]
    marker = L.marker(pos).addTo(map)
    marker.bindPopup("<b>#{d.type}</b>")

initData = () ->
  ref = new Firebase('https://blistering-fire-9499.firebaseio.com')
  locRef = ref.child('locs')
  locRef.on('value', showCurrent, ((e) -> console.log('error: ' + e.code)))

initTable = () ->
  Tabletop.init( {key: table_url, callback: initTypes, simpleSheet: true} )

locationFound = (loc) ->
  console.log(loc)
  position.setLatLng(loc.latlng)
  # position.setAccuracy(loc.accuracy)
  position.setAccuracy(0)
  
  position.addTo(map)

initPosition = () ->
  position = L.userMarker(home, {pulsing:false, accuracy:100, smallIcon:true})
  map.on("locationfound", locationFound)
  button = L.easyButton('fa-compass',findPosition,'', map)
  findPosition()

findPosition = () ->
  map.locate({
    watch: false,
    locate: true,
    setView: true,
    enableHighAccuracy: true
  })
  

$ ->

  initMap()
  initCurrent()
  initPosition()
  initTable()
  initData()

  map.on('click', click)
  d3.select("#create").on('click', make)
  

