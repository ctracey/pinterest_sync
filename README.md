
I wrote this ruby script to backup images for my pinterest boards. This script uses the Pinterest API.
https://developers.pinterest.com/docs/getting-started/introduction/

 - You need a pinterest account www.pinterest.com
 - Create a pinterest app (test mode is good)
 - You need an api token for your Pinterest account. (Pinterest recommends using Postman for testing)
 - You also need the id of the board you are backing up, use the Pinterest api explorer.
This guide is pretty good
https://weblizar.com/blog/generate-access-token-for-pinterest-feed-pro/

## Setup
To setup just make sure you have the right version and the required gems.

## Running
To start downloading your images run this command. The pin id is used as the image name.
`./bin/sync.rb <BOARD_ID> <API_TOKEN> <LOCAL_IMAGE_FOLDER>`

## Sync changes
Just run the script again, only images not already in the destination folder will be downloaded.

