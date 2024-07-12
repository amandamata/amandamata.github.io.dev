---
title: "How to remove sensitive information from commit history"
date: 2023-05-30T14:01:29-03:00
draft: false
tags: ["git"]
---

Today I learned something extremely useful: how to efficiently remove sensitive information from commit history.

I believe that at some point, we have all made the mistake of accidentally pushing sensitive information to a repository on GitHub. Simply deleting the information does not solve the problem because the commit history will still show the previous version with that sensitive information.

To address this issue, people often use git-filter-branch. However, I would like to introduce an even better alternative: BFG.

BFG is a powerful and user-friendly tool that allows you to securely remove confidential information from your repository's commit history. It provides a faster and more efficient solution compared to git-filter-branch.</br></br>
##### Scenario
We have the repository how-to-use-bfg.

In this repository, there was an appsettings.json file with sensitive information:

![bfg](/img/bfg1.png)

I deleted this sensitive information, made the commit and push, but the sensitive information still appears in the commit history:

![bfg2](/img/bfg2.png)

</br></br>

##### How to Use
The tutorial on the BFG website is not difficult, but I will describe it here in more detail to make the process easier to understand.

To use BFG, follow these steps:
1. Download the .jar file from the [BFG](https://rtyley.github.io/bfg-repo-cleaner/) website.
2. Clone the current repository using the command:
	```
	git clone git@github.com:amandamata/how-to-use-bfg.git --mirror
	```
3. Create a reference file containing the value you want to remove from the commit history. For example:
	```
	echo *VyieIqbij35MYV5&bIakKmq1Z > auth.txt
	```
4. Run BFG, passing the reference value, using the following command:
	```
	java -jar ~/Downloads/bfg-1.14.0.jar --replace-text auth.txt how-to-use-bfg.git
	```
5. Access the cloned repository directory:
	```
	cd how-to-use-bfg.git
	```
6. Run the following command:
	```
	git reflog expire --expire=now --all && git gc --prune=now --aggressive
	```
7. Push the changes:
	```
	git push
	```
	
After following these steps, your repository's commit history will be updated, and the sensitive information will be removed.


![bfg3](/img/bfg3.png)


Give BFG a try and ensure that your confidential information is protected in the commit history.
