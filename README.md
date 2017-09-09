# S3 to FTP

[![Code Climate](https://codeclimate.com/github/haanhduclinh/s3-to-ftp.png)](https://codeclimate.com/github/haanhduclinh/s3-to-ftp) [![CI](https://circleci.com/gh/haanhduclinh/s3-to-ftp.svg?style=shield&circle-token=17308ffeff6fb73d43e833efa38c1f4fd86224b4)](https://circleci.com/gh/haanhduclinh/s3-to-ftp) [![CI](https://travis-ci.org/haanhduclinh/s3-to-ftp.svg?branch=master)](https://travis-ci.org/haanhduclinh/s3-to-ftp) [![Coverage Status](https://coveralls.io/repos/github/haanhduclinh/s3-to-ftp/badge.svg?branch=master)](https://coveralls.io/github/haanhduclinh/s3-to-ftp?branch=master)

# Background
- Upload file from AWS S3 to FTP Server

# How to use
- make sure you already install `ruby 2.3.4` and bundler
- create `production.yml` by copy `config/settings/staging` and fill your information
- create `source.csv` like the sample `config/map.csv`. Please keep header always `aws_key,ftp_path`

```ruby
ENV=production ruby script/s3_to_ftp.rb
```

# How to contributor
- Folk project
- Create pull request. Please remember add `test` and make sure pass all of test.

# How to test this project on local environment
- run `fakes3`

```
fakes3 -r ~/fakes3_folder -p 4567
```

- run fake ftp-server

```
ruby scrip/ftp_server
```

- run test

```
ENV=test rake test
```

# Author

haanhduclinh@yahoo.com