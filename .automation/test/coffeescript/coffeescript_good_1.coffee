# Description
#   silly hubot scripts
#	These were created to blow off steam
#
# Commands:
#   `mona echo *` - repeats what you say
#
# Author:
#   admiralawkbar@github.com

###############################
# Drop Hammer array of images #
###############################
dropHammer = [
  "https://s1.yimg.com/uu/api/res/1.2/.kFQAfQ6KQmlf5ip8.UzNA--/dz0xMjMwO2g9NjkyO2FwcGlkPXl0YWNoeW9u/http://media.zenfs.com/en-US/video/video.snl.com/SNL_1554_08_Update_03_Harry_Caray.png",
  "http://media.tumblr.com/d12ea80b3a86dfc5fe36d3f306254fe4/tumblr_inline_mq1r0tbBCb1qz4rgp.jpg",
  "http://the-artifice.com/wp-content/uploads/2014/01/94309-160x160.png",
  "http://25.media.tumblr.com/35826348f2215069835c1733c75b29aa/tumblr_muuxmmBaOI1rw3gqyo2_250.gif",
  "http://data2.whicdn.com/images/78766805/large.jpg",
  "http://filmfisher.com/wp-content/uploads/2014/11/hunt_for_red_october.jpg",
  "http://cdn.meme.am/instances/500x/57495736.jpg",
]

###################
# Thank you array #
###################
thanks = [
  "You're welcome! Piece of cake...",
  "It was nothing..."
  "De nada...",
  "Danke...",
  "Merci...",
  "Bitte...",
  "De rien..."
  "Prego..."
]

#################################
# Start the robot for listening #
#################################
module.exports = (robot) ->

  ##############################
  # Show the adapter connected #
  ##############################
  robot.respond /ADAPTER$/i, (msg) ->
    msg.send robot.adapterName

  ##########################
  # Echo back the response #
  ##########################
  robot.respond /ECHO (.*)$/i, (msg) ->
    msg.send msg.match[1]

  ##################
  # Whats going on #
  ##################
  robot.respond /whats going on/i, (msg) ->
    msg.send "not much... robot stuff..."

  ###################
  # Drop the hammer #
  ###################
  robot.respond /drop the hammer/i, (msg) ->
     msg.send "Commencing the hammer dropping..."
     msg.send msg.random dropHammer

  ###############
  # Vape Nation #
  ###############
  robot.respond /lets roll/i, (msg) ->
    msg.send "First Class! Vape Nation!!! @beardofedu"

  ##############
  # Hubot Ping #
  ##############
  robot.respond /PING$/i, (msg) ->
    msg.send "PONG"

#######################
#######################
## END OF THE SCRIPT ##
#######################
#######################
