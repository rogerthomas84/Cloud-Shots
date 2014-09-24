Cloud Shots
===========

Take screenshots, upload them to Rackspace Cloud Files and copy the URL to your clipboard for easy sharing.

# Requirements

 * A Rackspace Cloud Files Account
 * API Username and Key for the dir.to shortcode generating service.

# Setup

`$ ./setup.sh`

After setup is complete, follow the steps listed. You can then remove this directory.

# Refreshing Tokens

To manually remove your authentication details, simply remove `.cloud-shots/cache/.tmp-auth`
When this file is more than 1800 seconds (30 minutes) old, it'll automatically be removed, and authentication with
Rackspace will happen again. This file will be refreshed with those credentials.
