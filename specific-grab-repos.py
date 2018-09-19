#!/usr/bin/python

import json
import urllib2
import sys

DATE="2017-06-01" # since push acvitiy and merge
SIZE="500" # KB
CONTRIBUTORS=5 # minimum contributors
MERGED_PRS=1 # minimum merged prs
# TODO: add threshold for time of merged pr

repos_url = "https://api.github.com/search/repositories?q=language:%s+pushed:>"+DATE+"+size:>"+SIZE+"&sort=stars&order=desc&page=%d&per_page=1000"

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

def filter_has_contributors_and_merged_prs(repos):
  filtered_repos = []
  for repo in repos:
    try:
      repo_full_name = repo
      repo_full_name = repo_full_name.replace("https://github.com/","")
      repo_full_name = repo_full_name.replace(".git","")
      print "processing full name",repo_full_name

      contributors_url = "https://api.github.com/repos/%s/contributors?" % repo_full_name
      contributors_url = access(contributors_url) # needed?
      contributors_res = json.loads(read(contributors_url))

      print "size contributors:",len(contributors_res)

      merged_prs_url = ("https://api.github.com/search/issues?q=type:pr+is:merged+repo:%s+updated:>="+DATE+"&sort=updated&order=desc") % repo_full_name
      merged_prs_url = access(merged_prs_url) # needed?
      merged_prs_res = json.loads(read(merged_prs_url))

      print "size merged prs:",str(merged_prs_res["total_count"])

      if len(contributors_res) > CONTRIBUTORS and merged_prs_res["total_count"] >= MERGED_PRS:
          filtered_repos.append(repo)
    except: # stupid forbidden?
        continue

  return filtered_repos

if __name__ == '__main__':
  if len(sys.argv) == 1:
    print "Usage: ./grap-repos.py <language> <number (max = 999)>"
  else:
    lang = sys.argv[1]
    number = int(sys.argv[2])
    pages = int((number / 100)+1)
    repos = map(lambda i: popular_repos(repos_url % (lang,i)), range(1,pages+1))

    repos = flatten(repos)
    repos = filter_has_contributors_and_merged_prs(repos)

    print "~=~=~=~=~=~"
    for i in xrange(len(repos)):
        print repos[i]
