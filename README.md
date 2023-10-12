# RailsKeyRotator

> _*⚠️ !!! WARNING !!! ⚠️*_
> _*⚠️ DON'T FORGET TO HANDOUT THE NEW KEY TO YOUR COLLEAGUES! ⚠️*_

## Procedure

1. First create a new key w/ `dip rails runner "puts ActiveSupport::EncryptedConfiguration.generate_key"` and deploy this in `RAILS_MASTER_KEY_NEW` on the targeted infrastructure.

2. While waiting on deploying this variable, create a new encrypted file:

   ```shell
   # Copy the output current credentials
   dip credentials show -e development
   # Backup current credentials
   mv -i config/credentials/development.yml.enc config/credentials/development.yml.enc.bak-$(date "+%Y-%m-%d-%H%M")
   # Backup current key
   mv -i config/credentials/development.key config/credentials/development.key.bak-$(date "+%Y-%m-%d-%H%M")
   # Save the new key into file
   echo d92599b046b58ab2d4158212e6d27162 > config/credentials/development.key
   # Create new credentials file w/
   dip credentials -e development
   # Verify content
   dip credentials show -e development
   ```

3. Commit to Github and deploy new encrypted file.

4. After a while when everything is back in sync replace `RAILS_MASTER_KEY` w/ the new key and delete `RAILS_MASTER_KEY_NEW`

### Process

When we've defined `RAILS_MASTER_KEY_NEW` it means we are rotating the encryption key for our credentials. What we want to do then is:

1. Check if we can decrypt the current credentials file with the new key

2. If we can, we will change `RAILS_MASTER_KEY` to equal `RAILS_MASTER_KEY_NEW`

3. If not, we will fallback to the old key, thus leave `RAILS_MASTER_KEY` alone

See: https://www.reddit.com/r/rails/comments/x4sujc/deploying_a_rotated_credentials_key_without/
