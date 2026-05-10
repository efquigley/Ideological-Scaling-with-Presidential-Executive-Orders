##packages
library(readr)
library(quanteda)
library(dplyr)
library(stringr)
library(distrom)
library(textir)
library(quanteda.textplots)

##load file
Exec_Orders <- read_csv("EO_All_WithText.csv")
#a loop that takes titles out of the text
for (i in 1:nrow(Exec_Orders)) {
  Exec_Orders$text[i] <- sub(Exec_Orders$title[i], "", Exec_Orders$text[i])
}

#all president signatures for later use
pres <- c("GWBOLD", "Biden", "BIDEN", "Obama", "OB#1", "Trump", "JOSEPH R. BIDEN JR.", "Barack Obama", "Donald Trump", "Donald J. Trump", "Bush", "George W. Bush", "George Bush")
pres <- str_c(pres, collapse = "|")

#eo stopwords for later use
eo_stopwords <- c(
  # Generic EO scaffolding
  "section","sections","u.s.c", "subsection","subsections","paragraph","paragraphs",
  "clause","clauses","order","orders","executive","presidential","proclamation","ii","iii",
  # Formal opening boilerplate
  "authority","vested","constitution","laws","united","states","america",
  "federal","government","department","agencies","agency","office","official",
  "secretary","director","administrator","council","board",
  # Common verbs in EO legal phrasing
  "shall","hereby","thereof","therein","herein","within","thereby","pursuant",
  # Frequent EO nouns that are usually boilerplate
  "policy","policies","program","programs","initiative","initiatives",
  "report","reports","guidance","requirements","implementation",
  "plan","plans","regulation","regulations","rule","rules",
  # Common structural/administrative filler
  "established","establish","establishment","create","created","creation",
  "amend","amended","amendment","termination","terminate","revoked","revoke",
  "effective","date","period","days","duration","applicable","application",
  # Geographic boilerplate
  "national","nation","state","states","district","territory","territories",
  "region","regions","regional",
  # Miscellaneous
  "executed","execution","signed","sign","issuance","issued",
  "implement","implementation")

#filter to include 2001-present 
EO_recents <- Exec_Orders %>% 
  filter(signing_date > "2001-01-18") %>% 
  arrange(signing_date)

## preprocessing 
#remove everything before first "Executive Order" for texts where preamble has important info
EO_recents$text <- sub(".*?Executive Order", "", EO_recents$text)
#remove preamble -- everything before "United States of America,"
EO_recents$text <- sub(".*?of the United States of America", "", EO_recents$text)
#remove all "\n"
EO_recents$text <-gsub("\n", "", EO_recents$text)
#remove section/sec
EO_recents$text <- str_remove_all(EO_recents$text, regex("(?i)sec(tion)?\\.?\\s*\\d+", ignore_case = TRUE))
#remove president name
EO_recents$text <- str_remove_all(EO_recents$text, regex(pres, ignore_case = TRUE))
#remove ending 
EO_recents$text <- sub("THE WHITE HOUSE.*", "", EO_recents$text, ignore.case = FALSE)
EO_recents$text <- sub("\\.EPS.*", "", EO_recents$text)


#prepping initial MIR
#creating author column for later use with MIR
EO_recents <- EO_recents %>% 
  mutate(president = case_when(
    signing_date > "2016-01-19" & signing_date < "2021-01-20" ~ "Trump",
    signing_date > "2021-01-19" & signing_date < "2025-01-20" ~ "Biden",
    signing_date > "2008-01-19" & signing_date < "2016-01-20" ~ "Obama",
    signing_date > "2001-01-19" & signing_date < "2008-01-20" ~ "Bush"))
#create party column
EO_recents <- EO_recents %>% 
  mutate(party = case_when(
    president == "Trump" ~ "R",
    president == "Bush" ~ "R",
    president == "Obama" ~"D",
    president == "Biden" ~ "D"
  ))


#create corpus with text from EOs
EO_corpus <- corpus(EO_recents,
                    text_field = "text",
                    meta = list(EO_recents$president, EO_recents$party, EO_recents$executive_order_number))

#tokenizing
EO_tokens <- quanteda::tokens(EO_corpus,
                    remove_punct = TRUE,
                    remove_numbers = TRUE) %>% 
  tokens_remove(stopwords(source = 'snowball')) %>%
  tokens_remove(eo_stopwords) %>% 
  tokens_wordstem() %>% 
  tokens_tolower() %>% 
  tokens_ngrams(n = 1:3) %>% 
  #remove letter labels (i.e. a, b, c, i)
  tokens_keep(min_nchar = 3)

# dfm
EO_dfm <- dfm(EO_tokens)

#trim words that occur in less than n and more than m of documents
EO_dfm <- dfm_trim(EO_dfm, min_docfreq = 3, docfreq_type = "count")
EO_dfm <- dfm_trim(EO_dfm, max_docfreq = .8*ndoc(EO_corpus), docfreq_type = "count")
#save dfm
save(EO_dfm, file = "EO_dfm.RData")

#top features
topfeatures(EO_dfm, n = 20)
#wordcloud
textplot_wordcloud(EO_dfm, max_words = 100)


##prepping MIR for indicating race
#read in files
topics <- read.csv("US-Executive-executive_orders_21.3 (1).csv")
cap_code <- read.csv("EO Cap Code Mapping - Sheet1.csv")
#convert class so it matches
topics <- topics %>% mutate(eo_number = as.character(eo_number))
#take what i need from topics file
topics <- topics %>% select(eo_number, subtopic)
#join topics to executive orders
EO_topics <- left_join(EO_recents, topics, by = c("executive_order_number" = "eo_number"))
#cap_code filtered
cap_code <- cap_code %>% select(3:7)
#join eo_topics with coded info
eo_coded <- inner_join(EO_topics, cap_code, by = c("subtopic" = "subtopic_no"))
#take out eos that are definitely not about race
eo_coded <- eo_coded %>% filter(racial != "No")
#arange by date
eo_coded <- eo_coded %>% arrange(signing_date)

#eos per year and overall
eo_coded %>% 
  count(year) %>% 
  print(n = 21)
count(eo_coded)

#create corpus with text from EOs about race
race_corpus <- corpus(eo_coded,
                    text_field = "text",
                    meta = list(eo_coded$president, eo_coded$party, eo_coded$executive_order_number))

#summary statistics of corpus
race_summary <- summary(race_corpus, n = 175)
race_summary %>% 
  summary()

#summary statistics by president
president_summary <- summary(race_corpus, showmeta = TRUE, n =175)
pres_sum_df <- as.data.frame(president_summary)

group_sum <- pres_sum_df %>% 
  group_by(president) %>% 
  summarize(
    Total_Documents = n(),
    Mean = round(mean(Tokens), digits = 2),
    Min = round(min(Tokens), digits = 2),
    Max = round(max(Tokens), digits = 2),
    SD = round(sd(Tokens), digits = 2))

#plot the summary statistics table
library(flextable)
summaryplot <- flextable(group_sum) %>% 
  add_header_lines(values = "Table 1: Summary Statistics") %>% 
  set_header_labels(president = "President",
                    Total_Documents = "Total Docs")
summaryplot

#tokenizing
race_tokens <- quanteda::tokens(race_corpus,
                              remove_punct = TRUE,
                              remove_numbers = TRUE) %>% 
  tokens_remove(stopwords(source = 'snowball')) %>%
  tokens_remove(eo_stopwords) %>% 
  tokens_wordstem() %>% 
  tokens_tolower() %>% 
  tokens_ngrams(n = 1:3) %>% 
  #remove letter labels (i.e. a, b, c, i)
  tokens_keep(min_nchar = 3)

# dfm
race_dfm <- dfm(race_tokens)

#trim words that occur in less than n and more than m of documents
race_dfm <- dfm_trim(race_dfm, min_docfreq = 3, docfreq_type = "count")
race_dfm <- dfm_trim(race_dfm, max_docfreq = .8*ndoc(race_corpus), docfreq_type = "count")
#save dfm
save(race_dfm, file = "race_dfm.RData")
