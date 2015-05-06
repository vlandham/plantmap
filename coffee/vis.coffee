
root = exports ? this

home =[47.67645, -122.39607]
map = null
markerLayer = null
current = null
position = null

allData = []

locRef = null

# table_url = "https://docs.google.com/spreadsheets/d/1Y_rBIlUwBYWDAz0Hp_SooQnESTbfhIZE-r5fGMRTbEA/pubhtml"
table_url = "1Y_rBIlUwBYWDAz0Hp_SooQnESTbfhIZE-r5fGMRTbEA"
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
  # $("#formType").typeahead({ source:types})
  d3.event.stopPropagation()

searchFilter = (e, suggestion) ->
  clearMarkers()
  filterData = allData.filter (d) ->
    d.type == suggestion.type
  addPoints(filterData)


initMap = () ->
  L.mapbox.accessToken = 'pk.eyJ1IjoibGFuZGhhbSIsImEiOiJ6cHE3dnFjIn0.RWhq_RIy4j_MQPnusn5dQw'
  map = L.mapbox.map('map', 'landham.cbfa3e4b').setView(home, 18)
  hash = new L.Hash(map)
  markerLayer = L.layerGroup().addTo(map)

initCurrent = () ->
  icon = L.MakiMarkers.icon({icon: "triangle", color: "#b0b", size: "m"})
  current = L.marker(home,{icon: icon})

  current.setLatLng(home)
  current.addTo(map)

initSearch = () ->
  typesB = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('type'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: allTypes#.map((d) -> d.type)
  })

  $('#search .typeahead').typeahead({
    hint: true,
    highlight: true,
    minLength: 1
  },
  {
    name: 'ttypes',
    source: typesB,
    display: 'type',
  }).on('typeahead:selected', searchFilter)

initTypes = (data, tabletop) ->
  allTypes = data
  initSearch()

clearMarkers = () ->
  if (map.hasLayer(markerLayer))
    map.removeLayer(markerLayer)
  markerLayer = new L.layerGroup()
  markerLayer.addTo(map)


addPoints = (data) ->
  data.forEach (d) ->
    pos = [d.lat, d.lon]
    marker = L.marker(pos).bindLabel(d.type).addTo(markerLayer)
    # marker.bindPopup("<b>#{d.type}</b>")

loadData = (snapshot) ->
  val = snapshot.val()
  d3.map(val).values().forEach (d) ->
    allData.push(d)
  addPoints(allData)

initData = () ->
  ref = new Firebase('https://blistering-fire-9499.firebaseio.com')
  locRef = ref.child('locs')
  locRef.on('value', loadData, ((e) -> console.log('error: ' + e.code)))

initTable = () ->
  Tabletop.init( {key: table_url, callback: initTypes, simpleSheet: true, debug:false} )

locationFound = (loc) ->
  position.setLatLng(loc.latlng)
  # position.setAccuracy(loc.accuracy)
  position.setAccuracy(0)

  position.addTo(map)

initPosition = () ->
  position = L.userMarker(home, {pulsing:false, accuracy:100, smallIcon:true})
  map.on("locationfound", locationFound)
  button = L.easyButton('fa-compass',findPosition,'', map)
  # findPosition()

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


