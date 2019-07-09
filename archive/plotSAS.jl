
folderloc = "/home/mei/liljondir/stored"

run(`ffmpeg -y -i $(folderloc)/07-29-2-%d.svg -threads 8 -vcodec libx264 -s 1920x1080 -b:v 2M /home/mei/liljondir/ffmpegvideo.mp4`)
