const http = require('http')
const createHandler = require('github-webhook-handler')
const handler = createHandler({ path: '/webhook', secret: (process.env.SECRET) })

const userArray = ['user1']

const teamDescription = 'Team of Robots'
const teamPrivacy = 'closed' // closed (visible) / secret (hidden) are options here

const teamName = process.env.GHES_TEAM_NAME
const teamAccess = 'pull' // pull,push,admin options here
const teamId = ''

// var creator = ""

http.createServer(function (req, res) {
  handler(req, res, function (err) {
    console.log(err)
    res.statusCode = 404
    res.end('no such location')
  })
}).listen(3000)

handler.on('error', function (err) {
  console.error('Error:', err.message)
})

handler.on('repository', function (event) {
  if (event.payload.action === 'created') {
    const repo = event.payload.repository.full_name
    console.log(repo)
    setTimeout(checkTeamIDVariable, 1000)
  }
})

handler.on('team', function (event) {
  // TODO user events such as being removed from team or org
  if (event.payload.action === 'deleted') {
    // const name = event.payload.team.name
    setTimeout(checkReposVariable, 5000)
  } else if (event.payload.action === 'removed_from_repository') {
    // const repo = event.payload.repository.full_name
    setTimeout(checkTeamIDVariable, 1000)
  }
})

function checkTeamIDVariable (repo) {
  if (typeof teamId !== 'undefined') {
    addTeamToRepo(repo, teamId)
  }
}

function checkReposVariable (org) {
  if (typeof orgRepos !== 'undefined') {
    //      for(var repo of orgRepos) {
    //        addTeamToRepo(repo, teamId)
    // }
    reCreateTeam(org)
  }
}

function addTeamToRepo (repo, teamId) {
  const https = require('https')
  const data = JSON.stringify({
    permission: teamAccess
  })

  const options = {
    hostname: (process.env.GHE_HOST),
    port: 443,
    path: '/api/v3/teams/' + teamId + '/repos/' + repo,
    method: 'PUT',
    headers: {
      Authorization: 'token ' + (process.env.GHE_TOKEN),
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  }
  let body = []
  const req = https.request(options, (res) => {
    res.on('data', (chunk) => {
      body.push(chunk)
    }).on('end', () => {
      body = Buffer.concat(body).toString()
      console.log(res.statusCode)
      console.log('added team to ' + repo)
    })
  })

  req.on('error', (error) => {
    console.error(error)
  })

  req.write(data)
  req.end()
}

function reCreateTeam (org) {
  const https = require('https')
  const data = JSON.stringify({
    name: teamName,
    description: teamDescription,
    privacy: teamPrivacy,
    maintainers: userArray
  })

  const options = {
    hostname: (process.env.GHE_HOST),
    port: 443,
    path: '/api/v3/orgs/' + org + '/teams',
    method: 'POST',
    headers: {
      Authorization: 'token ' + (process.env.GHE_TOKEN),
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  }
  // const body = []
  const req = https.request(options, (res) => {
    if (res.statusCode !== 201) {
      console.log('Status code: ' + res.statusCode)
      console.log('Added ' + teamName + ' to ' + org + ' Failed')
      res.on('data', function (chunk) {
        console.log('BODY: ' + chunk)
      })
    } else {
      console.log('Added ' + teamName + ' to ' + org)
    }
  })

  req.on('error', (error) => {
    console.error(error)
  })

  req.write(data)
  req.end()
}
