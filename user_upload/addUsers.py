# Script to add users to an App ID instance
#
# User data is provided in a csv file. To identity the App ID
# instance, the script needs the tenant ID and the region.
# Additionally, an API key for IBM Cloud is required to
# access the REST API functions.
#
# All the above values can be set in a .env file or set as
# environment variables.
#
# Written by Henrik Loeser, hloeser@de.ibm.com

import requests                 # to access REST API
import json                     # handle JSON data
import os                       # environment access
import csv                      # read CSV file
from dotenv import load_dotenv  # for loading .env
import secrets                  # for generating passwords


# load environment (variables)
load_dotenv()

appid_account_id = None
appid_region = None
ic_api_key = None
user_file = "users.csv"

# to preregister a profile
userIdP_template = {
    "idp": "cloud_directory",
    "idp-identity": "john@example.com",
    "profile": {
        "attributes": {
            "workshop_roles": ["student"]
        }
    }
}

# for the Cloud Directory
userCD_template = {
    "active": True,
    "status": "CONFIRMED",
    "emails": [{"value": "john@example.com", "primary": True}],
    "name": {
        "givenName": "John",
        "familyName": "Doe"
    },
    "password": "password123"}


# Turn the API key into a valid IAM oauth token
def getAuthTokens(api_key):
    url = "https://iam.cloud.ibm.com/identity/token"
    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    data = "apikey=" + api_key + "&grant_type=urn:ibm:params:oauth:grant-type:apikey"
    response = requests.post(url, headers=headers, data=data)
    return response.json()

# preregister the profile
# The function is used to populate the custom attributes for a new user
def preregisterUser(iam_token, userRecord):
    url = f"https://{appid_region}.appid.cloud.ibm.com/management/v4/{appid_account_id}/users"
    headers = {"Authorization": "Bearer "+iam_token,
               "Content-Type": "application/json", "accept": "application/json"}
    response = requests.post(url, headers=headers, json=userRecord)
    return response.json()

# sign up a new user for the Cloud Directory
# Note: This function is not used but could be as alternative.
#       Users can be notified that they are signed up.
def signupUser(iam_token, userRecord):
    url = f"https://{appid_region}.appid.cloud.ibm.com/management/v4/{appid_account_id}/cloud_directory/sign_up?shouldCreateProfile=true&language=en"
    headers = {"Authorization": "Bearer "+iam_token,
               "Content-Type": "application/json", "accept": "application/json"}
    response = requests.post(url, headers=headers, json=userRecord)
    return response.json()


# create a Cloud Directory user in App ID
def createUser(iam_token, userRecord):
    url = f"https://{appid_region}.appid.cloud.ibm.com/management/v4/{appid_account_id}/cloud_directory/Users"
    headers = {"Authorization": "Bearer "+iam_token,
               "Content-Type": "application/json", "accept": "application/json"}
    response = requests.post(url, headers=headers, json=userRecord)
    return response.json()

# print usage information
def printUsage():
    print()
    print("Usage: python3 addUsers.py")
    print()
    print("Required environment variables:")
    print("  APPID_ACCOUNT_ID:   The App ID tenant ID. See the service credentials.")
    print("  APPID_REGION:       The region of the App ID instance.")
    print("  IC_API_KEY:         IBM Cloud IAM API key to use.")
    print("  USER_FILE:          The csv file with user data. Default is 'users.csv'.")
    print()
    print("Set them in your environment or use a .env file.")



if __name__ == "__main__":
    # Check for variables and retrieve their values
    if 'APPID_ACCOUNT_ID' not in os.environ or os.environ['APPID_ACCOUNT_ID']=="":
        print("Need APPID_ACCOUNT_ID set - App ID tenant ID")
        printUsage()
        exit()
    else:
        appid_account_id = os.environ['APPID_ACCOUNT_ID']

    if 'APPID_REGION' not in os.environ or os.environ['APPID_REGION']=="":
        print("Need APPID_REGION set - region of App ID instance")
        printUsage()
        exit()
    else:
        appid_region = os.environ['APPID_REGION']

    if 'IC_API_KEY' not in os.environ or os.environ['IC_API_KEY']=="":
        print("Need IC_API_KEY set - IBM Cloud IAM API key")
        printUsage()
        exit()
    else:
        ic_api_key = os.environ['IC_API_KEY']

    if 'USER_FILE' in os.environ:
        user_file = os.environ['USER_FILE']

    print("generating auth tokens")
    authTokens = getAuthTokens(api_key=ic_api_key)
    print("authTokens:")
    print(json.dumps(authTokens, indent=2))
    iam_token = authTokens["access_token"]

    print("reading CSV file...")
    try:
        with open(user_file, newline='') as csvfile:
            # set up the CSV reader with ","" to delimit parts and ' for strings
            ureader = csv.reader(csvfile, delimiter=',', quotechar="'")
            # skip the first row with the header
            next(ureader, None)
            for row in ureader:
                # use the template and personalize it
                userIdP = userIdP_template
                userIdP['idp-identity'] = row[2]
                userIdP['profile']['attributes'] = json.loads(row[3])
                print("Registering this user:")
                print(json.dumps(userIdP))

                # make the API call
                res = preregisterUser(iam_token, userIdP)
                print("Result:\n", json.dumps(res))

                # use the template for the Cloud Directory and fill in values
                userCD = userCD_template
                userCD["emails"][0]["value"] = row[2]
                userCD["name"]["givenName"] = row[0]
                userCD["name"]["familyName"] = row[1]
                # generate a random and hopefully strong password
                userCD["password"] = secrets.token_urlsafe(nbytes=20)
                print("Creating this user:")
                print(json.dumps(userCD))

                # make the other API call
                res = createUser(iam_token, userCD)
                print("Result:\n", json.dumps(res))

        print("\n\n=========\nAll done...")
    except BaseException as err:
        # some basic exception handling
        print("Error adding the users.")
        print("Error: {0}".format(err))
        printUsage()
