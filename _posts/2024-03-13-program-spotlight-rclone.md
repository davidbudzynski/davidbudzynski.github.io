---
layout : post
title  : "Program Spotlight: Rclone"
date   : 2024-03-13 18:00
tags   : [Software, backup, cloud]
---

**Rclone** is one of those command-line tools that you don't realize you need
until you have a specific, annoying problem. It's a program for syncing files
to and from cloud storage, often described as "rsync for cloud storage". It
supports dozens of providers like Google Drive, OneDrive, Dropbox, and
S3-compatible storage.

But my favourite use case for rclone has nothing to do with the cloud at all.
It's copying photos and videos from a camera to my computer — and doing it
reliably, which a simple drag and drop often isn't.

## Why copying from a camera is harder than it looks

Copying photos and videos from a camera is a special case compared to regular
file transfers:

- **There are a lot of files.** A single day of shooting can produce hundreds
  or thousands of photos, plus several large video clips.
- **The files are big.** Video files especially can be several gigabytes each.
- **The source is flaky.** Cameras, memory cards, and card readers disconnect
  mid-transfer. USB hubs drop. Cards run out of space.
- **You want certainty.** You want to know that every file got copied, intact,
  and that no photo is silently corrupted or missing.

When you copy from one device to another using a regular file manager, you're
relying on a simple drag and drop. If the connection drops halfway through,
you're left with a partial file and no easy way to tell which files were
actually copied. You end up re-copying everything, or trusting that the
transfer went fine.

Rclone solves exactly this problem.

## Copying photos and videos with rclone

The basic command is deceptively simple:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera
```

`copy` transfers files from the source to the destination, skipping any files
that already exist in the destination. Run it again later and only new files
get copied. That alone makes it more reliable than a drag and drop — it's
idempotent.

I usually add `--progress` to see what's happening:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera --progress
```

### Why this is more reliable

1. **Atomic transfers.** Rclone copies each file to a temporary file and only
   renames it into place once the transfer finishes. A dropped connection never
   leaves a partial file behind pretending to be the real thing.
2. **Resumable.** If the camera disconnects, plug it back in and run the same
   command again. Files that already transferred are skipped and the remaining
   ones continue. No need to start over.
3. **Verification.** By default rclone compares file size and modification
   time. When you want to be extra sure, use `--checksum` to compare actual
   hashes:

   ```bash
   rclone copy /media/camera/DCIM ~/Pictures/Camera --checksum
   ```

4. **Checking.** After a copy, you can verify that source and destination
   match:

   ```bash
   rclone check /media/camera/DCIM ~/Pictures/Camera --checksum
   ```

   `check` compares both sides and reports any files that differ or are
   missing. That answers the "did I really copy everything?" question.

5. **Copy vs sync.** If you want the destination to exactly match the source
   (deleting files that were removed from the card), use `sync`:

   ```bash
   rclone sync /media/camera/DCIM ~/Pictures/Camera
   ```

   Note that `sync` is destructive, so it's worth being careful with it. I
   generally prefer `copy`.

### Filtering

Not everything on the card needs to come over. Maybe you only want the photos,
or only the videos. Rclone's filters make that easy:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera --include "*.JPG" --include "*.CR2"
```

Or the opposite, skipping videos you've already pulled:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera --exclude "*.MP4"
```

## Useful flags

The basic command is a good start, but rclone really shines once you start
combining its flags. Let's build up my typical camera copy step by step.

First, I want to see what's actually happening. `--progress` gives a live
progress bar with per-file and overall stats:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera --progress
```

Cameras and card readers aren't always reliable, so I also like to verify what
got copied. By default rclone compares file size and modification time, but I
can force it to compare actual hashes with `--checksum`. It's slower, but for a
once-a-day copy it's worth the peace of mind:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera --progress --checksum
```

Before committing to a new command, I always do a dry run. `--dry-run` shows
exactly what rclone would do without touching a single file:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera --dry-run
```

If the camera disconnected mid-transfer last time, `--ignore-existing` comes in
handy. It skips files that already exist in the destination without even
checking whether they differ, so you can fill in the gaps without re-reading
the whole card. `--size-only` is a similar trick for when the modification
times on the card aren't trustworthy.

Copying a few thousand photos one by one is slow, so I bump up the parallelism
with `--transfers`. The default is 4; on a decent machine 8 is fine. And if the
connection drops, `--retries` controls how many times rclone retries a failed
file before giving up (the default is 3):

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera \
    --progress --checksum --transfers 8 --retries 5
```

Sometimes I only want part of the card. `--max-size` skips files larger than a
given size, which is a neat way to leave the big video files behind:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera --max-size 100M
```

`--min-size` does the opposite, skipping files smaller than the limit. And if I
want to grab only what was shot recently, `--max-age` copies just the files
newer than a given age:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera --max-age 7d
```

Finally, for long overnight transfers, `--log-file` writes a log to a file
instead of the console, so I can check in the morning exactly what happened.

## From the card to the cloud

The "cloud" tag on this article isn't an accident. The same command that
reliably moves files from a camera card to your PC can then move them from your
PC to the cloud, or even from the camera straight to the cloud:

```bash
rclone copy /media/camera/DCIM remote:Photos/Camera
```

Once a remote is configured with `rclone config`, it behaves like any other
filesystem, so every trick above — checksums, checking, filtering, resuming —
works just the same. My workflow ends up being a single pipeline: card to PC,
then PC to the cloud, both with the same tool.

## Conclusion

If copying photos and videos from a camera is something you do regularly, a
drag and drop is honestly a gamble. Rclone turns the whole thing into a
repeatable, verifiable command that you can run again and again without worry.
It's one of those tools where once you start using it, you wonder how you ever
did without it.