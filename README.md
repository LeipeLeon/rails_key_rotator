# RailsKeyRotator

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rails_key_rotator

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rails_key_rotator

## Usage

> _*⚠️ !!! WARNING !!! ⚠️*_
> _*⚠️ DON'T FORGET TO HANDOUT THE NEW KEY TO YOUR COLLEAGUES! ⚠️*_

1. run the rake taks

        bundle rake key_rotator:rotate

    This will backup current key / credentials, create a new key and saves encrypts the credentails w/ this new key

1. Deploying this variable as an env `RAILS_MASTER_KEY_NEW`

1. Commit and deploy new encrypted file.

1. After a while when everything is back in sync replace `RAILS_MASTER_KEY` w/ the new key and delete `RAILS_MASTER_KEY_NEW`

### Process

When we've defined `RAILS_MASTER_KEY_NEW` it means we are rotating the encryption key for our credentials. What we want to do then is:

1. Check if we can decrypt the current credentials file with the new key

2. If we can, we will change `RAILS_MASTER_KEY` to equal `RAILS_MASTER_KEY_NEW`

3. If not, we will fallback to the old key, thus leave `RAILS_MASTER_KEY` alone

See: https://www.reddit.com/r/rails/comments/x4sujc/deploying_a_rotated_credentials_key_without/


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rails_key_rotator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rails_key_rotator/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RailsKeyRotator project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rails_key_rotator/blob/master/CODE_OF_CONDUCT.md).
