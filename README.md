**This GitHub repo contains the following**

*Two scripts that converts an AirTable to csv 
    
    This script requires the AirTable BaseID, Table ID/Name, ViewName and a Personal Access Token (PAT) which is generated from AirTable "BuilderHub"

    Note the Airtable token is saved as a secret in github so it is not directly shown in the code

*A workflow _".yml", which runs the scripts every X minutes to keep the local csv up to date with the NAC_Public AirTable

*index.html file, which plots the data from the csv's onto a map

*icons folder, which contains 4 pictures used as icons in the map
