import json
import sys
from os import getenv, path
from pprint import pprint

import click  # pylint: disable=import-error
import requests  # pylint: disable=import-error
from dotenv import load_dotenv  # pylint: disable=import-error

env = load_dotenv()
api_url = getenv("API_URL", default="https://api.github.com/graphql")
github_token = getenv("GITHUB_TOKEN", default=None)
m = [1, 2, 3]
print(m[len("t") :])

if github_token is None:
    sys.exit(
        "GitHub Token is not set."
        + "Please set the GITHUB_TOKEN env variable in your system or "
        + "the .env file of your project."
    )

client_id = getenv("CLIENT_ID", default="copy_labels.py")
headers = {
    "Authorization": "bearer {github_token}".format(github_token=github_token),
    "Accept": "application/vnd.github.bane-preview+json",
    "Content-Type": "application/json",
}


def make_request(query, query_variables):
    payload = {"query": query, "variables": query_variables}
    response = requests.post(api_url, data=json.dumps(payload), headers=headers)
    return response


def create_label(repo_id, label):
    """
    Create label in the supplied repo.

    :param repo_id: Unique ID that represents the repo in GitHub
    :type repo_id: str
    :param label: Object with label information.
    :type label: dict
    :return: GitHub API request response
    """

    query_variables = {
        "createLabelInput": {
            "color": label["color"],
            "description": label["description"],
            "name": label["name"],
            "repositoryId": repo_id,
        }
    }

    with open(
        path.join(path.dirname(__file__), "queries/create_label.gql"), "r"
    ) as query_file:
        query = "".join(query_file.readlines())

    response = make_request(query, query_variables).json()
    print("Created label {label}".format(label=label["name"]))

    return response


def get_labels(owner, repo):
    """
    Gets a list of labels from the supplied repo.
    :param owner: Repo owner GitHub login.
    :type owner: str
    :param repo: Repository name.
    :type repo: str
    :return: A tuple with the GitHub id for the repository and a list of labels defined in the repository
    """

    query_variables = {
        "owner": owner,
        "name": repo,
    }

    with open(
        path.join(path.dirname(__file__), "queries/get_repo_data.gql"), "r"
    ) as query_file:
        query = "".join(query_file.readlines())

    response = make_request(query, query_variables).json()

    status_code = response.status_code
    result = response.json()

    if status_code >= 200 and status_code <= 300:
        repo_id = result["data"]["repository"]["id"]
        labels = result["data"]["repository"]["labels"]["nodes"]

        return repo_id, labels
    else:
        raise Exception(
            "[ERROR] getting issue labels. Status Code: {status_code} - Message: {result}".format(
                status_code=status_code, result=result["message"]
            )
        )


def delete_label(label_id):
    """
    Delete the specified label
    :param label_id: Label's node id.
    :type label_id: str
    :return: GitHub API request response.
    """

    query_variables = {
        "deleteLabelInput": {"clientMutationId": client_id, "id": label_id}
    }

    with open(
        path.join(path.dirname(__file__), "queries/delete_label.gql"), "r"
    ) as query_file:
        query = "".join(query_file.readlines())

    payload = {"query": query, "variables": query_variables}
    result = requests.post(api_url, data=json.dumps(payload), headers=headers).json()

    return result


@click.command()
@click.option("--dry", is_flag=True)
@click.argument("source_repo")
@click.argument("target_repo")
def copy_labels(source_repo, target_repo, dry):
    """
    Copy labels from the source repository to the target repository.
    \f
    :param source: The full name of a GitHub repo from where the labels will be copied from. Eg. github/opensourcefriday
    :type source: str
    :param target: The full name of a GitHub repo to where the labels will be copied. Eg. github/opensourcefriday
    :type target: str
    :return:
    """
    source_owner, source_repo_name = source_repo.split("/")
    target_owner, target_repo_name = target_repo.split("/")

    try:
        print(
            "Fetching labels for {source_repo_name} repo.".format(
                source_repo_name=source_repo_name
            )
        )
        _, source_repo_labels = get_labels(source_owner, source_repo_name)
        print(
            "Fetched labels for {source_repo_name}".format(
                source_repo_name=source_repo_name
            )
        )

        print(
            "Fetching labels for {target_repo_name} repo.".format(
                target_repo_name=target_repo_name
            )
        )
        target_repo_id, target_repo_labels = get_labels(target_owner, target_repo_name)
        print(
            "Fetched labels for {target_repo_name}".format(
                target_repo_name=target_repo_name
            )
        )

        filtered_labels = list(
            filter(lambda x: x not in target_repo_labels, source_repo_labels)
        )

        if dry:
            print("This is just a dry run. No labels will be copied/created.")
            print(
                "{label_count} labels would have been created.".format(
                    label_count=len(filtered_labels)
                )
            )
            pprint(filtered_labels, indent=4)
        else:
            print(
                "Preparing to created {label_count} labels in {target_repo}".format(
                    label_count=len(filtered_labels), target_repo=target_repo
                )
            )

            for label in filtered_labels:
                create_label(target_repo_id, label)
    except Exception as error:
        sys.exit(error)

    print("Done")


if __name__ == "__main__":
    # Pylint doesn't know that @click.command takes care of injecting the
    # function parameters. Disabling Pylint error.
    copy_labels()  # pylint: disable=no-value-for-parameter
