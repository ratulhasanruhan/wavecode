# WaveCode 🌊

A beautiful Flutter app that encodes audio into stunning visual representations and decodes them back to audio.

## Features

- 🎙️ **Audio Recording**: Record audio directly from your device's microphone
- 📁 **File Import**: Import WAV and MP3 files from your device
- 🖼️ **Audio to Image**: Convert audio data into beautiful RGB image representations
- 🎵 **Image to Audio**: Decode images back into playable audio files
- 🎨 **Beautiful UI**: Modern design with glassmorphism effects and smooth animations
- 💾 **Save & Share**: Save generated images and decoded audio files
- 📱 **Cross-platform**: Works on both Android and iOS

## Technical Details

### Audio Processing
- Uses FFT (Fast Fourier Transform) for frequency analysis
- Converts audio amplitude data to RGB color values
- Supports WAV and MP3 file formats
- Real-time waveform visualization

### Image Generation
- Maps audio data to RGB pixel values
- Creates square images for optimal data storage
- PNG format for lossless compression
- Reversible encoding/decoding process


The app includes a sophisticated audio-to-image encoding algorithm that converts audio data into RGB values and vice versa, creating stunning visual representations of your audio files.