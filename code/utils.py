import os
import sys

import requests


def get_fhi_datafiles(filestr):
    files = []
    s = requests.Session()
    s.headers = {"Authorization": "token " + os.environ.get("GITHUB_TOKEN")}
    repo = "folkehelseinstituttet/surveillance_data"
    repo_url = f"https://api.github.com/repos/{repo}"
    covid19_dir = "covid19"
    # use trees API to get large list of files
    # contents API truncates to 1000 files
    try:
        # get the sha for the latest commit
        r = s.get(repo_url + "/git/ref/heads/master")
        r.raise_for_status()
        head_sha = r.json()["object"]["sha"]
        # get tree contents for top-level directory
        r = s.get(f"{repo_url}/git/trees/{head_sha}")
        r.raise_for_status()
        tree_root = r.json()
        # locate covid19 subdirectory
        for subtree in tree_root["tree"]:
            if subtree["path"] == covid19_dir:
                covidtree_url = subtree["url"]

        # finally, list covid19 directory contents
        r = requests.get(covidtree_url)
        r.raise_for_status()
        blobs = r.json()["tree"]
    except requests.HTTPException as e:
        print(f"Error accessing GitHub API: {e}", file=sys.stderr)
    else:
        for blob in blobs:
            name = blob["path"]
            if filestr in name and name.endswith(".csv"):
                # blobs API doesn't include download URL
                download_url = f"https://raw.githubusercontent.com/{repo}/{head_sha}/{covid19_dir}/{name}"
                files.append(download_url)

    return files
