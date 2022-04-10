"""
test for pylint
"""

from flask import Flask, escape, jsonify, request
from git import Repo
from git.exc import GitCommandNotFound, InvalidGitRepositoryError
from slack import WebClient
from slackeventsapi import SlackEventAdapter

import python_good_2 as conf

WebClient()
Flask(__name__)
escape("test")
jsonify({"foo": "var"})
SlackEventAdapter(signing_secret="test")

print(conf.TEST)
print(request.json["test"])

try:
    repo = Repo()
except (InvalidGitRepositoryError, GitCommandNotFound):
    pass
