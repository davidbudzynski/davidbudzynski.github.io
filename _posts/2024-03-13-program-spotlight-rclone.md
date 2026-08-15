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

Rclone has a lot of flags, but these are the ones I reach for most when dealing
with photos and videos:

| Flag | What it does |
|------|--------------|
| `--progress` | Shows a live progress bar with per-file and overall stats. |
| `--checksum` | Compares files by hash instead of just size and modification time. Slower but more thorough. |
| `--ignore-existing` | Skips files that already exist in the destination, without even checking if they differ. Great for filling in gaps. |
| `--size-only` | Compares files by size only. Handy when the modification times on the card aren't reliable. |
| `--dry-run` | Shows what rclone would do without actually copying anything. Good for safely checking a new command. |
| `--transfers` | Controls how many files are copied in parallel (default 4). Bump it up to speed through thousands of photos. |
| `--retries` | How many times rclone retries a failed transfer per file (default 3). |
| `--max-size` | Skips files larger than the given size, e.g. `--max-size 100M` to leave the big videos behind. |
| `--min-size` | Skips files smaller than the given size. |
| `--max-age` | Only copies files newer than the given age, e.g. `--max-age 7d`. |
| `--log-file` | Writes a log to a file instead of the console. Handy for long overnight transfers. |

Put together, a typical copy from my camera looks like this:

```bash
rclone copy /media/camera/DCIM ~/Pictures/Camera \
    --progress --checksum --transfers 8 --retries 5
```

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