# rails-sources

  - ![Build](http://img.shields.io/travis-ci/laurelandwolf/rails-sources.svg?style=flat-square)
  - ![Downloads](http://img.shields.io/gem/dtv/rails-sources.svg?style=flat-square)
  - ![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)
  - ![Version](http://img.shields.io/gem/v/rails-sources.svg?style=flat-square)


rails-sources is an extension to rails that gives the developer a unified way of handling external sources, like:

  - Database connections
  - Authenticated HTTP sessions
  - Message queues
  - And more!

**What does this solve?** Ever run into a situation where your application depends on (for example) rabbitmq, but your application boots much faster than rabbitmq? Now this will gracefully handle that situation!

## Using

Before you can use your new source you need to create a source class. Follow these steps:

  1. Make the file `app/sources/application_source.rb`.
  2. Copy this to that file:

  ``` ruby
  class ApplicationSource < Rails::Sources

  end
  ```

  3. Now create the source file for your connection: `app/sources/authentication_source.rb`
  4. It will look something like this:

  ``` ruby
  class AuthenticationSource < ApplicationSource

  end
  ```

Okay, we've got the start of our new source but we're not done yet. We need to define two fundamental concepts to every source object:

  1. `private#connect`, which is a catch all function that does what *you* need to do in order to connect to the external source.
  2. `private#open?`, which returns a boolean value denoting when your source is ready (*or not*).


So here's our new source again with those concepts:

``` ruby
class AuthenticationSource < ApplicationSource
  PUBLIC = ENV['AUTHENTICATION_PUBLIC']
  PRIVATE = ENV['AUTHENTICATION_PRIVATE']
  URI = "#{ENV['AUTHENTICATION_LOCATION']}/oauth/token"

  AUTHENTICATED_HTTP_REQUEST = HTTP.basic_auth(
    user: PUBLIC,
    pass: PRIVATE,
  )

  private def connect
    response = AUTHENTICATED_HTTP_REQUEST.post(
      URI,
      form: {
        grant_type: "client_credentials",
        scope: "users.read"
      }
    )

    raise unless response.status.success?

    return Account.new(oauth: response.parse['access_token'])
  end

  private def open?
    connection.oauth.present?
  end
end
```

There's two things we can learn from this example:

  1. Inside a `Source` you have access to the `public#connection` value, which is the **last returned value** from `private#connect`.
  2. If you `raise` or `fail` inside a `private#connect` call it will retry the connection!

Finally let's talk about using these sources. We can do so by first *establishing* the source:

``` ruby
connection = AuthenticationSource.establish
```

There are 4 keyword arguments for `public.establish`:

  - `required` (false): If this is set to true then we will wait until the connection is made.
  - `retries` (10): If the connection fails to open we'll keep giving it a shot until we run out of retries.
  - `fallback` (30s): If a connection fails to open we'll wait this long to start again
  - `global` (true): Once establishing a connection we'll use this connection forever

``` ruby
connection = AuthenticationSource.establish(required: true) # This will continue to retry forever, this is for stuff your business depends on!
connection = AuthenticationSource.establish(retries: 0) # This will never retry!
connection = AuthenticationSource.establish(fallback: 0) # This will immediately retry the failed establish.
connection = AuthenticationSource.establish(global: 0) # Now the connection is memoized, meaning that subsequent calls of `.establish` will return the same source.
```

## Installing

Add this line to your application's Gemfile:

    gem "rails-sources", "~> 1.0"

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install rails-sources


## Contributing

  1. Read the [Code of Conduct](/CONDUCT.md)
  2. Fork it
  3. Create your feature branch (`git checkout -b my-new-feature`)
  4. Commit your changes (`git commit -am 'Add some feature'`)
  5. Push to the branch (`git push origin my-new-feature`)
  6. Create new Pull Request


## License

Copyright (c) 2017 Laurel & Wolf

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
