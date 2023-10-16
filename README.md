# RailsKeyRotator

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rails_key_rotator

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rails_key_rotator

## Usage

> **Warning**
> **DON'T FORGET TO HANDOUT THE NEW KEY TO YOUR COLLEAGUES!**

1. Run the rake taks

        $ RAILS_ENV=production bundle exec rake key_rotator:rotate

        Starting process:
        -> Copy config/credentials/production.key -> config/credentials/production.key.bak-2023-10-15-084335
        -> Copy config/credentials/production.yml.enc -> config/credentials/production.yml.enc.bak-2023-10-15-084335
        -> Writing 774ef137809953c633f03233d3ec5d35 to config/credentials/production.key
        -> Writing the re-encrypted credentials to config/credentials/production.yml.enc

        Finished! The next steps are:

        - Deploy `RAILS_MASTER_KEY_NEW=774ef137809953c633f03233d3ec5d35` to your infrastructure
        - Share the new key w/ your colleagues
        - Commit changes in config/credentials/production.yml.enc
        - Update `RAILS_MASTER_KEY`and remove `RAILS_MASTER_KEY_NEW` from your infrastructure

    This will backup current key / credentials, create a new key and saves encrypts the credentails w/ this new key for the current `RAILS_ENV`


2. Deploying this variable as an env `RAILS_MASTER_KEY_NEW`

3. Commit and deploy new encrypted file.

4. After a while when everything is back in sync replace `RAILS_MASTER_KEY` w/ the new key and delete `RAILS_MASTER_KEY_NEW`

## Process

When we've defined `RAILS_MASTER_KEY_NEW` it means we are rotating the encryption key for our credentials. What we want to do then is:

1. Check if we can decrypt the current credentials file with the new key

2. If we can, we will change `RAILS_MASTER_KEY` to equal `RAILS_MASTER_KEY_NEW`

3. If not, we will fallback to the old key, thus leave `RAILS_MASTER_KEY` alone

See: https://www.reddit.com/r/rails/comments/x4sujc/deploying_a_rotated_credentials_key_without/


## Development

This project uses docker and [dip](https://github.com/bibendi/dip), a.k.a. the _Docker Interaction Program._

To use it:
```shell
gem install dip
dip provision
dip guard # run specs
```

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `dip bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/LeipeLeon/rails_key_rotator>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/LeipeLeon/rails_key_rotator/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RailsKeyRotator project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/LeipeLeon/rails_key_rotator/blob/master/CODE_OF_CONDUCT.md).
