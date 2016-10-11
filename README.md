# Ruby bindings for MS DHCPS API

This repository contains ffi-based ruby bindings for [MS DHCP server management API](https://msdn.microsoft.com/en-us/library/windows/desktop/aa363379(v=vs.85).aspx).

## Installation

Install ruby-dhcpsapi gem from [Rubygems](https://rubygems.org/gems/dhcpsapi):

  gem install dhcpsapi

## Usage

```ruby
require 'dhcpsapi'

api = DhcpsApi::Server.new('127.0.0.1')

clients = @api.list_clients('192.168.42.0')

api.create_client('192.168.42.254', '255.255.255.0', '01:01:02:03:04:05', 'test_client_1',
                       'test client 1 comment', 0)

# etc...
```

Please see [Integration tests](https://github.com/witlessbird/ruby-dhcpsapi/tree/master/integration_test) for additional examples.

## Development

Running integration tests requires a locally available MS DHCP server. These tests create and remove a variety of objects, including subnets, classes, options, option values, and clients are are probably better *NOT* executed against a production server.

## License

This software is licensed under the Apache 2 license, quoted below.

    Copyright (c) 2016 Dmitri Dolguikh <dmitri at appliedlogic dot ca>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
