---
title: "Understanding directories in Linux"
date: 2023-02-09T07:52:10-03:00
draft: false
tags: ["linux"]
---

If you just installed Linux and are used to the Windows directory structure, you might be wondering where the "C: drive" is. Understanding Linux directories can help you manage the system and understand how it works.

## Directory Structure: Windows vs. Linux

Windows and Linux have evolved differently in terms of directory structure. Linux is more similar to other Unix-like systems, such as macOS. In fact, Windows is the most different from most operating systems in terms of organization.

The Linux directory hierarchy is not more difficult, nor easier, it is simply different. Both the Windows "C: drive" and the Linux root (/) serve the same purpose but in different ways.

Linux systems follow the FHS (Filesystem Hierarchy Standard), maintained by the Linux Foundation.

## Types of Directories and Permissions

- **Symbolic Links**: Folders with an arrow are shortcuts to other folders or files. For example, /bin is a symbolic link to /usr/bin.
- **Protected Directories**: Folders with an "x" require root permissions to be accessed or modified.

## Main Directories in Linux

### /
- **Root**: The root directory, where all other directories and subdirectories reside.

### /bin
- **Binaries**: Contains executables of essential system programs, such as bash, cat, ls, etc. It is comparable to the "Program Files" folder in Windows.

### /boot
- **Boot**: Contains files necessary for the operating system to start.

### /cdrom
- **Legacy**: Directory where the disk image is mounted.

### /dev
- **Devices**: Contains files that represent hardware devices. For example, /dev/sda for disks.

### /etc
- **Configuration**: Stores system-wide configuration files, valid for all users.

### /home
- **Users**: Directory where the personal directories of users are located.

### /lib
- **Libraries**: Contains necessary software libraries for the operating system and applications.

### /media
- **Removable Media**: Directory where removable drives such as USB sticks are automatically mounted.

### /mnt
- **Mount**: Mount point for manually configured disk drives.

### /opt
- **Optional**: Contains additional software from manufacturers or proprietary software.

### /proc
- **Processes**: Virtual directory with information about the system and running processes.

### /root
- **Root's Home**: Personal directory of the root user.

### /run
- **Runtime**: Virtual directory in memory, deleted on shutdown. Contains information about logged-in users and running daemons.

### /sbin
- **System Binaries**: Contains executables that can only be used by the system administrator (root).

### /snap
- **Snap Packages**: Directories for Snap packages, a different packaging method for software.

### /srv
- **Services**: Used to store service data, such as web servers.

### /sys
- **System**: Contains files that interact directly with the kernel, such as drivers and firmware.

### /tmp
- **Temp**: Temporary files that are deleted on reboot.

### /usr
- **User or Unix System Resources**: Contains programs and libraries.

### /var
- **Variable**: Directory for files that are expected to grow in size, such as logs and system caches.
