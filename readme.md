# Pickle Packer
Packing pickles is no joke. Speed, dexterity, and constitution are all needed characteristics for a successful professional pickle packer. Pack and sell as many pickle jars as possible before your pickle packing workshop runs out of space.

## Controls
Drag jars and pickles using your mouse. P to pause.

## Extra
I ran into some bugs related to removing entities which made me not be able to finish in time, hence the Extra submission.

There is currently no win/lose condition, so you can pack pickles to your hearts content without worrying.

## Running the game

### Windows
Download/unpack zip and run the executable.

### Others
Install love2d and make sure you have the `love` binary in your path.

Download the love file and run with

```
love pickle-packer.love
```

 or download the source and run the game from the game/ directory with

```
love .
```

## Distributrion
```
cd game/
zip -r ../dist/pickle-packer.love *
```

### Windows
```
<<<<<<< HEAD
cat ~/Downloads/love-11.4-win64/lovec.exe dist/pickle-packer.love > dist64/pickle-packer64.exe
cp ~/Downloads/love-11.4-win64/SDL2.dll ~/Downloads/love-11.4-win64/OpenAL32.dll ~/Downloads/love-11.4-win64/license.txt ~/Downloads/love-11.4-win64/love.dll ~/Downloads/love-11.4-win64/lua51.dll ~/Downloads/love-11.4-win64/mpg123.dll ~/Downloads/love-11.4-win64/msvcp120.dll ~/Downloads/love-11.4-win64/msvcr120.dll dist64/
cd dist64/
zip -r ../pickle-packer64-1.1.0.zip *
```


```
cat ~/Downloads/love-11.4-win32/lovec.exe dist/pickle-packer.love > dist32/pickle-packer32.exe
cp ~/Downloads/love-11.4-win32/SDL2.dll ~/Downloads/love-11.4-win32/OpenAL32.dll ~/Downloads/love-11.4-win32/license.txt ~/Downloads/love-11.4-win32/love.dll ~/Downloads/love-11.4-win32/lua51.dll ~/Downloads/love-11.4-win32/mpg123.dll ~/Downloads/love-11.4-win32/msvcp120.dll ~/Downloads/love-11.4-win32/msvcr120.dll dist32/
cd dist32/
zip -r ../pickle-packer32-1.1.0.zip *
```

## Unimplemented ideas
* Different kinds of vegetables
* Sentient pickles
* Exploding pickles
* Spreading mold
* Pickle freshness
* Bugs that eat the pickles
* Birds that steal the pickles
