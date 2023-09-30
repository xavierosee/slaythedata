# Using Terraform to declare the needed resources

### AWS S3 Buckets

We'll be using 3 S3 buckets for this project:
- one hosting all the data (we'll limit it to 2.5GB to avoid going over the 5GB limit of the free tier)
- one where we'll simulate streaming data by copying, via a cron job, new JSON files at a set frequency.
