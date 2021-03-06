package org.baeldung.web.controller.rest;

import java.util.List;

import javax.validation.Valid;

import org.baeldung.persistence.model.User;
import org.baeldung.persistence.service.IRedditService;
import org.baeldung.reddit.util.PostDto;
import org.baeldung.web.RedditTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.JsonNode;

@Controller
@RequestMapping(value = "/api")
public class RedditRestController {
    @Autowired
    private RedditTemplate redditTemplate;

    @Autowired
    private IRedditService service;

    // === API Methods

    @RequestMapping(value = "/posts", method = RequestMethod.POST)
    @ResponseBody
    public final List<String> submit(@Valid @RequestBody PostDto postDto) {
        return service.submitPost(postDto);
    }

    @RequestMapping(value = "/posts")
    @ResponseBody
    public String checkIfAlreadySubmitted(@RequestParam("url") final String url, @RequestParam("sr") final String sr) {
        final JsonNode node = redditTemplate.searchForLink(url, sr);
        return node.get("data").get("children").toString();
    }

    @RequestMapping(value = "/subredditAutoComplete")
    @ResponseBody
    public JsonNode subredditAutoComplete(@RequestParam("term") final String term) {
        return service.SearchSubredditNames(term);
    }

    // === Non Restful

    // @RequestMapping("/login")
    // public final String redditLogin() {
    // final JsonNode node = redditTemplate.getUserInfo();
    // service.loadAuthentication(node.get("name").asText(), redditTemplate.getAccessToken());
    // return "redirect:home.html";
    // }

    @RequestMapping("/post")
    public final String showSubmissionForm(final Model model) {
        final boolean isCaptchaNeeded = getCurrentUser().isCaptchaNeeded();
        if (isCaptchaNeeded) {
            final String iden = redditTemplate.getNewCaptcha();
            model.addAttribute("iden", iden);
        }
        return "submissionForm";
    }

    // === private

    private User getCurrentUser() {
        return (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

}
