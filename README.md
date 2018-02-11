# Instrumentality

[![CircleCI](https://circleci.com/gh/Ruenzuo/instrumentality.svg?style=svg&circle-token=71523995bd17c73c1ce365df507d24cb0bc1e3c4)](https://circleci.com/gh/Ruenzuo/instrumentality)
[![Coverage Status](https://coveralls.io/repos/github/Ruenzuo/instrumentality/badge.svg?branch=master)](https://coveralls.io/github/Ruenzuo/instrumentality?branch=master)

`instr` is a command line interface for profiling tools already installed in macOS. Under the hood uses [`dtrace`](http://dtrace.org/blogs/) to get information from running processes. 

## Important

`dtrace` is pre-installed in macOS but in order to use it you have to disable System Integrity Protection. You can learn more about SIP from [Apple Support page](https://support.apple.com/en-us/HT204899) and make a conscious decision about disabling it in your system or your continuous integration environment.

## Installation

`instr` is distributed as a Ruby gem and can be installed using the following command:

```bash
$ gem install instrumentality
```

## Try it yourself

To get a feeling about what `instr` can do, after disabling SIP and installing the gem try this:

```bash
$ instr profile file-activity Preferences --interactive
```

Now open `System Preferences.app`. See the output? These are the files the application proccess tried to access.

## Learn more

`instr` can be used to run any dtrace script you provide, but it also includes a few bundled. Learn how to [integrate it in your projects using CocoaPods](https://github.com/Ruenzuo/instr-ios-sample-app) and how to use the included benchmark tool to [measure performance as part of your delivery pipelines](https://github.com/Ruenzuo/instr-jenkins-docker-image).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Ruenzuo/instrumentality.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
