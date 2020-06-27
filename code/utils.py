import requests
import os

def get_fhi_datafiles(filestr):
    files = []
    headers = { 'Authorization': 'token ' + os.environ.get('GITHUB_TOKEN') }

    contents = requests.get('https://api.github.com/repos/folkehelseinstituttet/surveillance_data/contents/covid19', headers=headers)
    
    if contents.status_code == 200:
        for content in contents.json():
            if filestr in content['name'] and 'csv' in content['name']:
                files.append(content['download_url'])
    else:
        print('Error accessing GitHub API.')

    return files