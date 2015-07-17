# Hacker News Job Scraper

This is a little web scraping script that will pull down all of the job post data from Hacker News, format it and store it in a json file. There's also functionality to index it into Elasticsearch.

Included are the *Who's Hiring*, *Who's Looking*, and *Freelancer* threads, posted each month.

The scraper will auto-remove the current month from the existing data set and re-scrape it, so this is useful throughout the month and people continue to post in these threads.

Tested with ES >= version 1.4, 2.0 included.

# Usage

Install Node.js and npm, then run `npm install`.

`npm start` will do all the web scraping and save the data into a local `data.json` file.

`npm run indexer` will index the data into Elasticsearch, using monthly indexes with the pattern `hn_jobs-YYYY-MM`.

![screencap](http://i.imgur.com/AtnMlQ6.png)