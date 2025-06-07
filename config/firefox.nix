{
  policies = {
    # Extensions = {
    #   Install = [
    #     "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
    #   ]
    # };
    # SearchEngines = {
    #  Remove = [
    #     "DuckDuckGo",
    #     "Google",
    #     "Bing",
    #     "Ecosia"
    #   ];
    #   Add = [
    #     {
    #       Name = "DuckDuckGo",
    #       URLTemplate = "https://duckduckgo.com/?q={searchTerms}",
    #       Method = "GET",
    #       IconURL = "https://duckduckgo.com/favicon.ico",
    #       Alias = "ddg"
    #     }
    #   ];
    #   Default = "DuckDuckGo"
    # };
    # ExtensionSettings = {
    #   "google@search.mozilla.org": {
    #     installation_mode = "blocked"
    #   };
    #   "bing@search.mozilla.org": {
    #     installation_mode = "blocked"
    #   };
    #   "ecosia@search.mozilla.org": {
    #     installation_mode = "blocked"
    #   };
    #   "amazondotcom@search.mozilla.org": {
    #     installation_mode = "blocked"
    #   };
    #   "youtube@search.mozilla.org": {
    #     installation_mode = "blocked"
    #   };
    #   "yahoo@search.mozilla.org": {
    #     installation_mode = "blocked"
    #   };
    #   "startpage@search.mozilla.org": {
    #     installation_mode = "blocked"
    #   };
    #   "ebay@search.mozilla.org": {
    #     installation_mode = "blocked"
    #   }
    # };
    SearchSuggestEnabled = false;
    DisablePocket = true;
    DisableFirefoxStudies = true;
    DisableFormHistory = true;
    DisableTelemetry = true;
    # EnableTrackingProtection = {
    #   Value = true;
    #   Cryptomining = true;
    #   Fingerprinting = true;
    #   EmailTracking = true;
    #   #Exceptions = [
    #   #  "https://netflix.com"
    #   #]
    # };
    FirefoxHome = {
      Search = true;
      TopSites = false;
      SponsoredTopSites = false;
      Highlights = false;
      Pocket = false;
      SponsoredPocket = false;
      Snippets = false;
      Locked = true;
    };
    FirefoxSuggest = {
      WebSuggestions = false;
      SponsoredSuggestions = false;
      ImproveSuggest = false;
      Locked = true;
    };
    HttpsOnlyMode = "force_enabled";
    LegacySameSiteCookieBehaviorEnabled = false;
    LegacySameSiteCookieBehaviorEnabledForDomainList = [
      "192.168.*"
      "localhost"
    ];
    NetworkPrediction = false;
    NewTabPage = false;
    PopupBlocking = {
      Allow = [
        "http://example.org/"
      ];
      Default = true;
      Locked = true;
    };
    PostQuantumKeyAgreementEnabled = true;
    UserMessaging = {
      ExtensionRecommendations = false;
      UrlbarInterventions = false;
      MoreFromMozilla = false;
      FirefoxLabs = true;
    };
    SSLVersionMin = "tls1.2";
  };
}
