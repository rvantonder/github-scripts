#!/usr/bin/python

import json
import urllib2
import sys

repos_url = 'https://api.github.com/search/repositories?sort=stars&order=desc&q=language:%s&page=%d&per_page=1000'

def access(url):
  f = open("token.txt", "r")
  token = f.readline().strip()
  f.close()
  return url.replace('?','?access_token=%s&' % token)

def read(s):
  response = urllib2.urlopen(s)
  return response.read()

def flatten(l):
  return [item for sublist in l for item in sublist]

def popular_repos(req_url):
  url = access(req_url)
  res = json.loads(read(url))
  repos = []
  for repo in res["items"]:
    repos.append(repo["clone_url"])
  return repos

if __name__ == '__main__':
  if len(sys.argv) == 1:
    print "Usage: ./grap-repos.py <language> <number (max = 1000)>"
  else:
    lang = sys.argv[1]
    number = int(sys.argv[2])
    pages = int((number / 100)+1)
    repos = map(lambda i: popular_repos(repos_url % (lang,i)), range(1,pages+1))

    repos = flatten(repos)

    for i in xrange(0,int(number)):
      print repos[i]
