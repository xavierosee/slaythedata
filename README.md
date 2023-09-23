# Slay the Data

Back in 2020, Mega Crit Games, developer of popular roguelike deck-building game **Slay the Spire**, [released a dataset of 77 million runs](https://www.reddit.com/r/slaythespire/comments/jt5y1w/77_million_runs_an_sts_metrics_dump/).

This is my attempt of trying to build something with it, most specifically an end-to-end Data Engineering project.

## Orchestrating the management of all the VMs used for this project

While I could theoretically run all this on my machine (and watch as my Macbook Pro takes flight to then crash and burn), I decided to use Terraform for managing the servers, and Ansible for configuring them.