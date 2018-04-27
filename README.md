# YOUTUBE-DOWNLOAD TO TELEVISION

## Requirements
\# apt install -y youtube-dl

\# apt install -y ffmpeg

## Description
I have observed files downloaded from youtube do not have the proper audio codec to be watched on samsung and lg televisions (this might also be true with other brands).

This script calls youtube-dl to download the video or the playlist given in argument.  Then calls ffmpeg to produce a .avi file using: (1) AAC audio codec; (2) H.264 video codec.

The result is a playable file on televisions I own (and probably others).

## Usage
./youtube-samsung

When called without options and arguments, the script shows the help page.
