- [Audio-Tag  - a sample tool to deal with audio tags. read, edit and write](#org1ab2213)
  - [Warning: there may be lots of bugs, so when using this lib, be very careful!!](#org12f1d41)
  - [Usage](#org54fa742)
    - [Simple example](#org5b2de48)
  - [Copyright](#org98553ed)
- [Todo](#org81b6ca4)
  - [use union to make tag only appear only once](#org626dc25)
  - [bug fix](#orge678e77)
  - [speed up](#orgd634e0d)
  - [add support for other formats](#org74df678)
  - [add support for cover image](#orgd172f47)
  - [add support for auto write to temp file and replace original file](#orgdd7d953)


<a id="org1ab2213"></a>

# Audio-Tag  - a sample tool to deal with audio tags. read, edit and write

For now, only support flac, support for other formats may be added later. Only test using sbcl 2.0.11, utf-8 is supported. Feel free to open issues!


<a id="org12f1d41"></a>

## Warning: there may be lots of bugs, so when using this lib, be very careful!!


<a id="org54fa742"></a>

## Usage


<a id="org5b2de48"></a>

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

CL-USER> (format-abstract:append-audio-tag a :lyrics '("2" "3"));;be careful, "2","3" should be string, not int
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


<a id="org98553ed"></a>

## Copyright

Copyright (c) 2021 I-Entropy (<1041559871@qq.com>)


<a id="org81b6ca4"></a>

# Todo


<a id="org626dc25"></a>

## use union to make tag only appear only once


<a id="orge678e77"></a>

## bug fix


<a id="orgd634e0d"></a>

## speed up


<a id="org74df678"></a>

## add support for other formats


<a id="orgd172f47"></a>

## add support for cover image


<a id="orgdd7d953"></a>

## add support for auto write to temp file and replace original file