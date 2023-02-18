---
title: "Understanding folders in linux"
date: 2023-02-09T07:55:10-03:00
draft: false
tags: ['linux']
---
<button type="button" class="btn btn-light btn-xs"><a href="/" style="text-decoration:none;color:black">posts</a></button>
<button type="button" class="btn btn-light btn-xs"><a href="/pt-pt/folders-in-linux" style="text-decoration:none;color:black">pt</a></button>

You've just installed linux and you're used to the structure of windows and its directories, so you'll take a look in your file manager looking for the disk C: and you can't find it...
Knowing Linux directories can help administer the system and understand how it works.

If we analyze windows and linux, they ended up evolving differently in terms of directory structure. Linux is much more like any other system with unix roots like macOS. In fact, windows, considering most existing operating systems, is the one with the most different organization.

The linux directory hierarchy is not more difficult nor is it easier it is simply different, both the windows C: disk and the linux root serve the same thing but do it differently.

Linux systems have the **FHS**, Filesystem hierarchy standard system hierarchy, a standard maintained by the Linux foundation.


There are folders that have an arrow and others that have an x.
The folders that have the arrow are called symbolic links, which are shortcuts to other folders or files, these folders can be accessed but when you enter them you are entering another directory. As an example, /bin, if you look at its properties, you will see that it is destined for the /usr/bin folder, so if you are going to use the terminal to make a shell script or run bash, you do not need to run the /usr command /bin/bash and yes /bash.


The folders that contain the x mean that they cannot be accessed without navigating as root, the common user does not have permission to write in any folder with x.


Let's look at the functionality of the folders

**/**

The **/** directory is what we call the root directory, it is where all other directories and subdirectories will be housed.

**/bin**

Binaries

In this directory you will find the executables of various operating system programs, such as bash, cat, ls, etc. Also finding symlinks and shell script. This folder is comparable to the Disk C: Windows Files and Programs folder.

**/boot**

Contains files needed for the operating system to start.

**/cdroom**

Legacy directory, disk image will be mounted in this directory.

**/dev**

Devices

Inside that folder you will find files that correspond to your hardware, files that can be configurable and change the way a certain device works. That's why disk drives are called **/dev/sda** and some number. The number only appears if there are partitions on that disk.

Curiosity: **/dev/null** is a black hole directory, which loses all information that is sent to it.

**/etc**

Edit to config or et cetera

The function of this folder is to keep the system configuration files, in a system wide way, that is, for all users of the system and not specific configurations of a user, these specific configurations are in /home.


**/home**

Where common system users are located, within each user folder, it is possible to have application-specific settings for the user in question.

**/lib**

Library


**/lib lib32 lib64 libx32**

All of them are folders that contain software libraries for the operating system and installed applications, a newly installed program can add libs in these folders are compared with windows dlls.

**/media**

It is the folder where the system's removable drives will be automatically mounted, such as a pendrive, external hard drive or other disk including network drives mapped by samba for example.

**/mnt**

Mount

Intended to be a mount point for disk drives, when done manually by the user using fstab.


**/opt**

Optional

In that folder where you can find software installed by manufacturers that ship computers with Linux or by proprietary software, for example.


**/proc**

Processes

Where are files that contain information about the system and its processes. It's a virtual directory, they don't really exist on disk, they are created every time you start your computer.


**/root**

Like the home directory, but for the root user.

**/run**

Runtime

It is a virtual directory, loaded into the computer's memory and erased when shutting down. Contains information such as logged in users, running daemons, etc.

**/sbin**

System binaries

It also stores binaries, programs that can only be used by the system administrator sudo root.

**/snap**

Finds directories for snaps packages, it's a different form of packaging. Snap package support is standard in ubuntu.

**/srv**

Services

If you use a web or sftp server, you can store files here that will be accessible to other users. It is possible to mount it from an external disk.

**/sys**

System

Here, files that interact directly with the kernel are stored, such as drivers and firmware. It is also temporary.


**/tmp**

Temp

Files are erased during reboot.

**/usr**

Directory that changed function. Usr can mean two things, user or unix system resources. Nowadays it contains program files and libs.

**/var**

Variable

Variables directory, files that are expected to grow in size, backup files, log, system cache for example.
