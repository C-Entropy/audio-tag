- [Audio-Tag  - a sample tool to deal with audio tags. read, edit and write](#orgae6864e)
  - [Warning: there may be lots of bugs, so when using this lib, be very careful!!](#orgaf200de)
  - [Usage](#org103be58)
    - [Simple example](#org77f77aa)
  - [Copyright](#org879b76d)
- [Todo](#org3059a96)
  - [use union to make tag only appear only once](#orge41c45d)
  - [bug fix](#orga02b3d8)
  - [speed up](#org49be9b6)
  - [add support for other formats](#orgbf5e0ab)
  - [add support for cover image](#org3d0c0e3)
  - [add support for auto write to temp file and replace original file](#org3c4806b)


<a id="orgae6864e"></a>

# Audio-Tag  - a sample tool to deal with audio tags. read, edit and write

For now, only support flac, support for other formats may be added later. Only test using sbcl 2.0.11, utf-8 is supported. Feel free to open issues!


<a id="orgaf200de"></a>

## Warning: there may be lots of bugs, so when using this lib, be very careful!!


<a id="org103be58"></a>

## Usage


<a id="org77f77aa"></a>

### Simple example

```lisp
; SLIME 2.26.1
CL-USER> (ql:quickload "audio-tag")
To load "audio-tag":
  Load 1 ASDF system:
    audio-tag
("audio-tag")

CL-USER> (setf a (audio-tag:make-audio "/home/nil/Attic/temp/春江花月夜《编钟与编磬》_群星_春江花月夜.flac"))
#<FORMAT-ABSTRACT:FLAC-FILE {100334F9F3}>

CL-USER> (format-abstract:show-tags a)
ALBUM: (春江花月夜)
ARTIST: (群星)
DATE: (2003)
ENCODER: (Lavf56.4.101)
LYRICS: ([00:01.58]纯音乐，请欣赏)
TITLE: (春江花月夜《编钟与编磬》)
TRACKNUMBER: (2)
NIL

CL-USER> (format-abstract:get-audio-tag a :lyrics)
("[00:01.58]纯音乐，请欣赏")
T

CL-USER> (format-abstract:set-audio-tag a :lyrics NIL)
NIL

CL-USER> (format-abstract:get-audio-tag a :lyrics)
NIL
T

CL-USER> (format-abstract:show-tags a)
ALBUM: (春江花月夜)
ARTIST: (群星)
DATE: (2003)
ENCODER: (Lavf56.4.101)
LYRICS: NIL
TITLE: (春江花月夜《编钟与编磬》)
TRACKNUMBER: (2)
NIL

CL-USER> (format-abstract:append-audio-tag a :lyrics '("2" "3"))
("2" "3")

CL-USER> (format-abstract:show-tags a)
ALBUM: (春江花月夜)
ARTIST: (群星)
DATE: (2003)
ENCODER: (Lavf56.4.101)
LYRICS: (2 3)
TITLE: (春江花月夜《编钟与编磬》)
TRACKNUMBER: (2)
NIL

CL-USER> (format-abstract:append-audio-tag a :lyrics '("1"))
("1" "2" "3")

CL-USER> (format-abstract:set-audio-tag a :lyrics '("1"))
("1")

CL-USER> (format-abstract:set-audio-tag a :lyrics 'NIL)
NIL

CL-USER> (format-abstract:set-audio-tag a :a '("1"));;tag-key will be created auto.
NIL

CL-USER> (audio-tag:save-audio a "/home/nil/Attic/temp/a.flac"  :if-exists :supersede)
NIL

CL-USER> (setf b (audio-tag:make-audio "/home/nil/Attic/temp/a.flac"))
#<FORMAT-ABSTRACT:FLAC-FILE {10035FFA63}>

CL-USER> (format-abstract:show-tags b)
TRACKNUMBER: (2)
TITLE: (春江花月夜《编钟与编磬》)
ENCODER: (Lavf56.4.101)
DATE: (2003)
ARTIST: (群星)
ALBUM: (春江花月夜)
A: (1)
NIL
```


<a id="org879b76d"></a>

## Copyright

Copyright (c) 2021 I-Entropy (<1041559871@qq.com>)


<a id="org3059a96"></a>

# Todo


<a id="orge41c45d"></a>

## use union to make tag only appear only once


<a id="orga02b3d8"></a>

## bug fix


<a id="org49be9b6"></a>

## speed up


<a id="orgbf5e0ab"></a>

## add support for other formats


<a id="org3d0c0e3"></a>

## add support for cover image


<a id="org3c4806b"></a>

## add support for auto write to temp file and replace original file