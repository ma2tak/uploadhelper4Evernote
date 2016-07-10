# Upload Helper for Evernote with Files
====

This Ruby script enables to upload local files to Evernote

## Description

This scrpit provides these steps.

1. gather filenames of current directory and sub directories.
2. upload each file to your evernote as an each note.

Kindly see the blog if you're interested in the background why I made. But I think it's boring :)

## Requirement

- evernote-thrift

```sh
    $ gem install everntoe-thrift
```

- Evernote Developer Token


You can get a developer token here. [Evernote Developers](https://dev.evernote.com/intl/jp/doc/articles/authentication.php#devtoken)


## Usage

```
    $ ruby uploadHelper2Evernote.rb
```


## Licence

Copyright (c) 2007-2015 by Evernote Corporation, All rights reserved.

Because this script based on the sample codes from evernote-thrift gem.

```
/*
 * Copyright (c) 2007-2015 by Evernote Corporation, All rights reserved.
 *
 * Use of the source code and binary libraries included in this package
 * is permitted under the following terms:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 */
```


## Author

[maple](https://github.com/maple)

