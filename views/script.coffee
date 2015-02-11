class IsPennsylvaniaAvenueClosed

  castle: ["38.8977", "-77.0366"]
  radius: .5 # Maximum allowed update distance in KM

  constructor: ->
    $('a').click @update

  # https://stackoverflow.com/questions/27928/how-do-i-calculate-distance-between-two-latitude-longitude-points
  distance: (lat1, lon1, lat2, lon2) ->
    R = 6371 # Radius of the earth in km
    dLat = @deg2rad(lat2 - lat1)
    dLon = @deg2rad(lon2 - lon1)
    a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(@deg2rad(lat1)) * Math.cos(@deg2rad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    R * c

  deg2rad: (deg) ->
    deg * Math.PI / 180

  success: (position) =>
    latitude = position.coords.latitude
    longitude = position.coords.longitude
    distance = @distance(latitude, longitude, @castle[0], @castle[1])

    if distance > @radius
      alert("You're not anyplace near Pennsylvania Avenue.")
    else
      $('form').submit()

  error: (err) ->
    alert("We can't update the status without first confirming your location")

  update: (e) =>
    e.preventDefault()
    return unless Modernizr.geolocation
    navigator.geolocation.getCurrentPosition @success, @error

jQuery ->
  new IsPennsylvaniaAvenueClosed()
