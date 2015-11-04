# Hacker News Job Scraper

This is a little web scraping script that will pull down all of the job post data from Hacker News, format it and store it in a json file. There's also functionality to index it into Elasticsearch.

Included are the *Who's Hiring*, *Who's Looking*, and *Freelancer* threads, posted each month.

The scraper will auto-remove the current month from the existing data set and re-scrape it, so this is useful throughout the month and people continue to post in these threads.

Tested with ES >= version 1.4, 2.0 included.

# Usage

Install Node.js and npm, then run `npm install`.

## Getting data

`npm start` will do all the web scraping and save the data into a local `data.json` file.

Any data currently stored for the current month will be removed so that you end up with the most current dataset.

## Indexing data

`npm run indexer` will index the data into Elasticsearch, using monthly indexes with the pattern `hn_jobs-YYYY-MM`.

## Resetting data

`npm run reset YYYY MM` will remove data for a given year and month. This is useful for getting an updated dataset for a past month.

![screencap](http://i.imgur.com/AtnMlQ6.png)