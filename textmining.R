# https://spark.rstudio.com/guides/textmining/

# install.packages("gutenbergr")
library(gutenbergr)
# install.packages("sparklyr")
library(sparklyr)
# spark_install(version = "2.1.0")

sc <- spark_connect(master = "local")

gutenberg_works()  %>%
  filter(author == "Twain, Mark") %>%
  pull(gutenberg_id) %>%
  gutenberg_download() %>%
  pull(text) %>%
  writeLines("mark_twain.txt")

gutenberg_works()  %>%
  filter(author == "Doyle, Arthur") %>%
  pull(gutenberg_id) %>%
  gutenberg_download() %>%
  pull(text) %>%
  writeLines("arthur_doyle.txt")

# Imports Mark Twain's file

# Setting up the path to the file in a Windows OS laptop
twain_path <- paste0("file:///", getwd(), "/mark_twain.txt")
twain <-  spark_read_text(sc, "twain", twain_path) 

# Imports Sir Arthur Conan Doyle's file
doyle_path <- paste0("file:///", getwd(), "/arthur_doyle.txt")
doyle <-  spark_read_text(sc, "doyle", doyle_path) 

all_words <- doyle %>%
  mutate(author = "doyle") %>%
  sdf_bind_rows({
    twain %>%
      mutate(author = "twain")}) %>%
  filter(nchar(line) > 0)

all_words <- all_words %>%
  mutate(line = regexp_replace(line, "[_\"\'():;,.!?\\-]", " ")) 

all_words <- all_words %>%
  ft_tokenizer(input.col = "line",
               output.col = "word_list")

head(all_words, 4)

all_words <- all_words %>%
  ft_stop_words_remover(input.col = "word_list",
                        output.col = "wo_stop_words")

head(all_words, 4)

all_words <- all_words %>%
  mutate(word = explode(wo_stop_words)) %>%
  select(word, author) %>%
  filter(nchar(word) > 2)

head(all_words, 4)

all_words <- all_words %>%
  compute("all_words")


# Wrap all in one dplyr statement -----------------------------------------

all_words <- doyle %>%
  mutate(author = "doyle") %>%
  sdf_bind_rows({
    twain %>%
      mutate(author = "twain")}) %>%
  filter(nchar(line) > 0) %>%
  mutate(line = regexp_replace(line, "[_\"\'():;,.!?\\-]", " ")) %>%
  ft_tokenizer(input.col = "line",
               output.col = "word_list") %>%
  ft_stop_words_remover(input.col = "word_list",
                        output.col = "wo_stop_words") %>%
  mutate(word = explode(wo_stop_words)) %>%
  select(word, author) %>%
  filter(nchar(word) > 2) %>%
  compute("all_words")

# data analysis -----------------------------------------------------------

word_count <- all_words %>%
  group_by(author, word) %>%
  tally() %>%
  arrange(desc(n)) 

word_count

doyle_unique <- filter(word_count, author == "doyle") %>%
  anti_join(filter(word_count, author == "twain"), by = "word") %>%
  arrange(desc(n)) %>%
  compute("doyle_unique")

doyle_unique

doyle_unique %>%
  head(100) %>%
  collect() %>%
  with(wordcloud::wordcloud(
    word, 
    n,
    colors = c("#999999", "#E69F00", "#56B4E9","#56B4E9")))

all_words %>%
  filter(author == "twain",
         word == "sherlock") %>%
  tally()

twain %>%
  mutate(line = lower(line)) %>%
  filter(instr(line, "sherlock") > 0) %>%
  pull(line)


spark_disconnect(sc)
