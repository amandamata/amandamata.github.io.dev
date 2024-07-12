---
title: "Removing sensitive data from commit history"
date: 2023-05-30T14:01:29-03:00
draft: false
tags: ["git"]
---

Today, I learned something extremely useful: how to efficiently remove sensitive information from commit history.

At some point, many of us make the mistake of accidentally pushing sensitive information to a GitHub repository. Simply deleting the information from the current repository does not solve the problem, as the commit history will still show the previous version with that information.

To address this issue, many turn to `git-filter-branch`. However, I want to introduce an even better alternative: BFG.

BFG is a powerful and easy-to-use tool that allows you to remove confidential information from your repository's commit history safely. It offers a quicker and more efficient solution compared to `git-filter-branch`.

#### Scenario

We have the repository [how-to-use-bfg](https://github.com/amandamata/how-to-use-bfg).

In this repository, there was an `appsettings.json` with sensitive information.

![bfg1](/img/bfg1.png)

I deleted this sensitive information, made the commit and push, but the sensitive information still appears in the history.

![bfg2](/img/bfg2.png)

#### Prerequisites

- Git installed on your machine.
- Java Runtime Environment (JRE) installed to run the BFG `.jar` file.

#### How to Use

The tutorial on the BFG website is quite straightforward, but here is a more detailed description to facilitate the process:

1. Download the .jar file from the [BFG](https://rtyley.github.io/bfg-repo-cleaner/) website.
2. Clone the current repository using the command:
	```shell
	git clone git@github.com:amandamata/how-to-use-bfg.git --mirror
	```
3. Create a reference file containing the value you want to remove from the commit history. For example:
	```shell
	echo *VyieIqbij35MYV5&bIakKmq1Z > auth.txt
	```
4. Run BFG, passing the reference value, using the following command:
	```shell
	java -jar ~/Downloads/bfg-1.14.0.jar --replace-text auth.txt how-to-use-bfg.git
	```
5. Access the cloned repository directory:
	```shell
	cd how-to-use-bfg.git
	```
6. Run the following command:
	```shell
	git reflog expire --expire=now --all && git gc --prune=now --aggressive
	```
7. Push the changes:
	```shell
	git push
	```

After following these steps, your repository's commit history will be updated, and the sensitive information will be removed.

![bfg3](/img/bfg3.png)

#### Conclusion

Conclusion
Removing sensitive information from the commit history is crucial for maintaining the security and privacy of your project. The BFG Repo-Cleaner offers an efficient and quick way to do this. If you have any questions or would like to share your experience using BFG, feel free to leave a comment below.

I hope this guide has been helpful. Good luck with cleaning your repository!
