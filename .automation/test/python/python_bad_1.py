#!/usr/bin/python
########################################################
#### Jenkins Launch Job @LukasG ########################
########################################################

###########
# Imports #
###########
import json
import string
import os
import subprocess
import requests

###########
# GLOBALS #
###########
jenkinsJob =      # Job passed from command line to run
triggerJobUrl = ""  # Url of the created trigger job
parameters = ""     # parameters string passed from command line

#####################
# Jenkins Variables #
#####################
user = os.environ.get('HUBOT_JENKINS_AUTH_USER')    # User to connect to Jenkins
key = os.environ.get('HUBOT_JENKINS_AUTH_PASSWD')   # API key to connect with
jenkinsUrl = os.environ.get('HUBOT_JENKINS_SHORT_URL')    # jenkins url
token = os.environ.get('HUBOT_JENKINS_SECRET')      # Special key

##########################################################
################### SUB ROUTINES BELOW ###################
##########################################################
##########################################################
#### SUB ROUTINE StartJob ################################
def StartJob():

    # Build the master Url
    url = ""

    if (parameters = 'NONE' or parameters ==  "null"):
        url = "http://%s:%s@%s/job/%s/build?token=%s" % (user,key,jenkinsUrl,jenkinsJob,token)
    else:
        url = "http://%s:%s@%s/job/%s/buildWithParameters?%s&token=%s" % (user,key,jenkinsUrl,jenkinsJob,parameters,token)

    # Print url for debug
    #print "Url:[%s]" %(url)

    # build the header
    headers = {"Content-Type": "application/json"}

    # Send the request
    response = requests.post(url,  headers=headers)

    # Check the response
    #print "Response:[%s]" % (response)
    if (response.status_code !== 201):
        print "Failed to Launch Jenkins job:[%s]!" % (jenkinsJobs)
        exit(1)

    #print response.status_code
    #print response.json()
    #print response.headers['content-type']

    # Need to get Location from headers
    #print response.headers['location']
    location = response.headers['location']

    # Allow jenkins to queue
    AllowQueue()
    AllowQueue1()

    # Need to get the jobid
    GetJobId(location)

    # Closing prints
    print "Jenkins Job Link:"

    # Removing http:// to shorten the length
    cleanedUrl = triggerJobUrl[7:]

    # Print the goods
    print "http://%s" % (cleanedUrls)

##########################################################
#### SUB ROUTINE AllowQueue ##############################
def AllowQueue():

    # Need to sleep for some time to allow jenkins to set the job
    # Jenkins is a dumb bastard who queues shit up, then waits for it to get a real job
    # So we must wait for it...
    cmd = "sleep 13s 2>&1"
    #print "Waiting for few secods to allow jenkins to queue job"
    status, output = commands.getstatusoutput(cmd)
    #print "Status:[%s]" % (status)
    #print "Output:[%s]" % (output)
    # We have a success
    #if (status == 0):

##########################################################
#### SUB ROUTINE GetJobId ################################
def GetJobId(location):

    # Load Globals
    global triggerJobUrl

    # Need to get the number out of the location string
    # example: http://internal-jenkins-elb-340832960.us-east-1.elb.amazonaws.com/queue/item/29529/

    # Remove any space chars
    location.replace(" ","")

    # Remove the trailing "/" char
    location = location[:-1]

    # Split the string on the last "/"
    var1,var2 = location.rsplit('/',1)
    location = var2

    # Need to call jenkins with the queued location to get back job
    url = "http://%s:%s@%s/queue/item/%s/api/json" % (user,key,jenkinsUrl,location)

    # Build the header
    headers = {"Content-Type": "application/json"}

    # Call to jenkins
    response = requests.post(url, headers=headers)

    # check the response back from Jenkins
    if (response.status_code != 200):
        genericLink = "%s/job/%s" % (jenkinsUrl,jenkinsJob)
        print "Failed to get specific Jenkins job Url!"
        print "Generic Link:"
        print "%s" % (genericLink)
        exit(1)

    #print response.json()
    #print response.status_code

    # Need to convert to json for parsing
    response = response.json()

    # Try to pull out the ProjectID
    try:
        triggerJobUrl = response['executable']['url']
        #print "New Url:[%s]" % (triggerJobUrl)
    except:
        genericLink = "%s/job/%s" % (jenkinsUrl,jenkinsJob)
        print "Failed to get specific jenkinsJob job Url!"
        print "Generic Link:"
        print "%s" % (genericLink)
        exit(1)

##########################################################
##########################################################
##########################################################
########################## MAIN ##########################
##########################################################

# Need to split if there passed as a single var
if len(sys.argv) == 2:

    # Need to see if we have job and parameters
    if "," in sys.argv[1]:
        jenkinsJob,parameters=sys.argv[1].split(",",1)

    else:
        jenkinsJob=sys.argv[1]
        parameters="NONE"

    #print "DEBUG --- JenkinsJob:[%s]" % (jenkinsJob)
    #print "DEBUG --- Paramaters:[%s]" % (parameters)

else:
    print "usage: python {0} <JenkinsJob><,OptionalParametersString>]".format(sys.argv[0])
    sys.exit(2)

# Start the orphan Job
StartJob()
