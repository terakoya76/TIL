# Transcribe Audio

## record
https://linux.die.net/man/1/arecord
```bash
$ arecord -l
**** List of CAPTURE Hardware Devices ****
card 1: MICROPHONE [USB MICROPHONE], device 0: USB Audio [USB Audio]
  Subdevices: 0/1
  Subdevice #0: subdevice #0
card 3: C920 [HD Pro Webcam C920], device 0: USB Audio [USB Audio]
  Subdevices: 1/1
  Subdevice #0: subdevice #0

# plughw:<Card ID>,<Device ID>
$ arecord -D plughw:3,0 -r 16000 -f S16_LE test.wav
Recording WAVE 'test.wav' : Signed 16 bit Little Endian, Rate 16000 Hz, Mono
^CAborted by signal Interrupt...
arecord: pcm_read:2221: read error: Interrupted system call
```

## transcribe
https://github.com/openai/whisper

```bash
$ whisper test.wav --language Japanese
```
