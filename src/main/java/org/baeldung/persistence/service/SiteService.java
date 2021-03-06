package org.baeldung.persistence.service;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import org.baeldung.persistence.dao.SiteRepository;
import org.baeldung.persistence.model.Site;
import org.baeldung.persistence.model.User;
import org.baeldung.reddit.util.SiteArticle;
import org.baeldung.web.exceptions.FeedServerException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.rometools.rome.feed.synd.SyndEntry;
import com.rometools.rome.feed.synd.SyndFeed;
import com.rometools.rome.io.FeedException;
import com.rometools.rome.io.SyndFeedInput;
import com.rometools.rome.io.XmlReader;

@Service
public class SiteService implements ISiteService {

    @Autowired
    private SiteRepository repo;

    private final Logger logger = LoggerFactory.getLogger(getClass());

    // API

    @Override
    public List<Site> getSitesByUser(User user) {
        return repo.findByUser(user);
    }

    @Override
    public void saveSite(Site site) {
        repo.save(site);
    }

    @Override
    public Site findSiteById(Long siteId) {
        return repo.findOne(siteId);
    }

    @Override
    public void deleteSiteById(Long siteId) {
        repo.delete(siteId);
    }

    @Override
    public List<SiteArticle> getArticlesFromSite(Long siteId) {
        final Site site = repo.findOne(siteId);
        return getArticlesFromSite(site);
    }

    @Override
    public List<SiteArticle> getArticlesFromSite(Site site) {
        List<SyndEntry> entries;
        try {
            entries = getFeedEntries(site.getUrl());
        } catch (final Exception e) {
            throw new FeedServerException("Error Occurred while parsing feed", e);
        }
        return parseFeed(entries);
    }

    @Override
    public boolean isValidFeedUrl(String feedUrl) {
        try {
            return getFeedEntries(feedUrl).size() > 0;
        } catch (final Exception e) {
            return false;
        }
    }

    // Non API

    private List<SyndEntry> getFeedEntries(String feedUrl) throws IllegalArgumentException, FeedException, IOException {
        final URL url = new URL(feedUrl);
        final SyndFeed feed = new SyndFeedInput().build(new XmlReader(url));
        return feed.getEntries();
    }

    private List<SiteArticle> parseFeed(List<SyndEntry> entries) {
        final List<SiteArticle> articles = new ArrayList<SiteArticle>();
        for (final SyndEntry entry : entries) {
            articles.add(new SiteArticle(entry.getTitle(), entry.getLink(), entry.getPublishedDate()));
        }
        return articles;
    }

}
