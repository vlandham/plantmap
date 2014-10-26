
root = exports ? this

home =[47.67645, -122.39607]
map = null
circle = null

locRef = null

table_url = "https://docs.google.com/spreadsheets/d/1Y_rBIlUwBYWDAz0Hp_SooQnESTbfhIZE-r5fGMRTbEA/pubhtml"
allTypes = null

allLocs = null

click = (e) ->
  circle.setLatLng(e.latlng)
  console.log(e.latlng)

currentLocation = () ->
  circle.getLatLng()

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
  console.log(data)
  saveData(data)
  $('#myModal').modal('hide')

  d3.event.preventDefault()


make = () ->
  loc = currentLocation()
  console.log(loc)
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


initCircle = () ->
  circle = L.circle([51.508, -0.11], 5, {
    color: 'red',
    fillColor: '#f03',
    fillOpacity: 0.5
  })

  circle.setLatLng(home)
  circle.addTo(map)

initTypes = (data, tabletop) ->
  console.log(data)
  allTypes = data

initData = () ->
  ref = new Firebase('https://blistering-fire-9499.firebaseio.com')
  locRef = ref.child('locs')

initTable = () ->
  Tabletop.init( {key: table_url, callback: initTypes, simpleSheet: true} )

$ ->

  initMap()
  initCircle()
  initTable()
  initData()

  map.on('click', click)
  d3.select("#create").on('click', make)
  

