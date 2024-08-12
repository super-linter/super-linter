var teamId = "teamId"
var booleanTest = false;

function checkTeamIDVariable(teamId, booleanTest) {
  if (typeof teamId != "undefined" || booleanTest) {
    console.log(teamId)
  }
}

checkTeamIDVariable(teamId, booleanTest)
