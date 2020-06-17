const fs = require('fs');
const axios=require('axios');

// UPDATE THESE (and set your GITHUB_TOKEN in the environment)
const owner = 'LukasTestOrganization';
const repo = 'TestImportRepo';
const token = process.env.GITHUB_TOKEN

// Configure HTTP client
const url = `https://api.github.com/repos/${owner}/${repo}/issues`;
axios.defaults.headers.post.Accept = "application/vnd.github.v3+json";
axios.defaults.headers.post.Authorization = `token ${token}`;

//-----------------------------------------------------------------
// getGitHubUser function - maps TFS users to GitHub users
const userMap = [
    [ "Sample User1",   "admiralawkbar"],
    [ "Sample User2",   ""],              // Not mapped in the GitHub side
    [ "No Suchuser",    "admiralawkbar"]
];

function getGitHubUser( user ) {
    var foundUser = userMap.find( function( value, index, results) {
        return (user === value[0]);
    });
    if (foundUser === undefined) {
        return "";
    } else {
        return foundUser[1];
    }
}

//-----------------------------------------------------------------
// createIssue function
// Work Item Type and state are stored as a labels
function createIssue( title, workitem_type, state, description, assignee ) {
    var body = {
        title: title,
        body: description,
        assignees: [ getGitHubUser(assignee) ],
        labels: [ workitem_type, state ]
    };

    var response = axios.post(url, body)
    .then((res) => {
        var issueNumber = res.data.number;
        console.log(`Created issue #${issueNumber}`);
    })
    .catch((error) => {
        console.error(error)
    });
}

//-----------------------------------------------------------------
fs.readFile('wit.csv', function(err, charBuffer) {
    var fileContents = charBuffer.toString();
    var lines = fileContents.split('\n');
    // The first line is the server name, so skip it
    // The second line is column headers (skipped) which is hard coded as:
    //      ID,Work Item Type,Title,Assigned To,State,Tags
    // We are capturing all of it as historical description
    for( var i=2; i< lines.length; i++ ) {
        columns = lines[i].split(',');
        var id = columns[0];
        var workitem_type = columns[1];
        var title = columns[2];
        var user = columns[3];
        var state = columns[4];
        var tags = columns[5];

        var description = `Imported ${workitem_type} #${id} from TFS, TITLE: ${title}, ASSIGNED TO: ${user}, STATE: ${state}, TAGS: ${tags}`;

        if (id > 0 ) {
            createIssue( title, workitem_type, state, description, user );
        }
    }
});
