**This GitHub repo contains the following**

*A script that converts an AirTable to csv (airtable_to_csv)
    This script requires the AirTable BaseID, Table ID/Name, and a Personal Access Token (PAT) which is generated from AirTable "BuilderHub"

    Note the Airtable token is saved as a secret in github so it is not directly shown in the code

*An workflow "update-airtable.yml", which runs the script every 5 minutes to keep the csv up to date with the AirTable

*index.html file, which plots the data from the csv onto a map

*icons folder, which contains 4 pictures used as icons in the map
