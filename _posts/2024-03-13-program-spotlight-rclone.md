---
layout : post
title  : "Program Spotlight: Rclone"
date   : 2026-08-15 10:00
tags   : [Software, backup, cloud, photography]
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

## Why not just use `cp`, `mv`, or the file manager?

Fair question. If you're comfortable in a terminal, `cp -r` or `mv` gets the
job done, and the GUI file manager is right there too. So why bother with
rclone?

The short answer: those tools copy files, but they don't care about the
outcome. When the source is a flaky camera card, that distinction matters.

`cp` doesn't know what was already copied. Run it again and it re-copies
everything, or with `-u` it compares modification times and still re-reads a
lot of files. If the card disconnects halfway through, `cp` errors out and
leaves a partial file behind — and it won't tell you that other files got
silently truncated. It never verifies anything; it just copies.

GUI file managers have the same problem under the hood. A dropped connection
leaves partial files, there's no way to tell which files actually made it, and
verifying "did everything copy correctly" is up to you squinting at file sizes.

`rsync` is closer to what you want — it's resumable with `--partial`, can
verify with `--checksum`, and skips files that are already there. If you only
ever copy locally from a card reader, rsync is a perfectly good answer.

What rclone adds on top is that it treats the camera the same way it treats a
cloud remote. The exact same command that fills in the gaps after a dropped
transfer, with the same flags, works when you point it at Google Drive instead
of your card. And because rclone copies to a temporary file and renames it into
place only when the transfer finishes, a partial file never survives a dropped
connection. For me, that's the difference between "I hope it copied" and "I
know it copied."

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

## The full workflow

Putting it all together, my routine looks like this. First, copy everything
from the card to my Pictures folder, verifying as I go:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera --progress --checksum
```

Then I confirm nothing was missed or corrupted:

```bash
rclone check /media/camera/DCIM ~/Pictures/Camera --checksum
```

Once the check passes, the card can be cleared. `move` transfers files and
deletes them from the source in one go — running it now simply removes the
files from the card, now that they're safely on disk:

```bash
rclone move /media/camera/DCIM ~/Pictures/Camera
```

Or you can just format the card in the camera. The important thing is that you
only clear it after the check passes.

Finally, the same command pushes the photos to the cloud, where they're backed
up away from the house:

```bash
rclone copy ~/Pictures/Camera remote:Photos/Camera --progress --checksum
```

That's the whole pipeline: card to PC, PC to cloud, every step verified with
the same tool and the same flags.

## Browsing with rclone mount

Sometimes I don't want to copy everything at once, or I just want to look at
what's on the card before deciding. `rclone mount` turns a source into a normal
filesystem that you can browse in any file manager:

```bash
mkdir -p ~/mnt/camera
rclone mount /media/camera/DCIM ~/mnt/camera
```

Leave that running and the card shows up as a regular folder. The same trick
works for cloud remotes, which is a nice way to browse cloud storage without
installing a provider's app:

```bash
mkdir -p ~/mnt/photos
rclone mount remote:Photos ~/mnt/photos
```

When you're done, unmount it:

```bash
fusermount -u ~/mnt/camera
```

One caveat: when you copy files out of a mount, you're back to regular file
operations — no checksums, no atomic renames, none of the safety nets from
earlier. I use mounts for browsing and poking around, but for the actual copy I
always use the commands above.

## Conclusion

If copying photos and videos from a camera is something you do regularly, a
drag and drop is honestly a gamble. Rclone turns the whole thing into a
repeatable, verifiable command that you can run again and again without worry.
It's one of those tools where once you start using it, you wonder how you ever
did without it.