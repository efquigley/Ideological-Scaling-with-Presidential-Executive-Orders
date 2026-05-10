library(ggplot2)

##initial MIR without subsetting for race
#group by author
dfm.grouped <- dfm_group(EO_dfm, groups = president)
#define terms
X <- convert(EO_dfm, to = "data.frame")
Y<- ifelse(EO_dfm@docvars$party == "R", 1, 0)
#run model!
fit <- dmr(counts = X[,2:ncol(X)], covars = Y, cl = NULL)
save(fit, file = "fit.RData")
#store coefficients
c1 <- coef(fit)
#make coefficient frame
tmp <- as.data.frame(as.matrix(t(c1)))
tmp$token <- rownames(tmp)
# put term frequencies back on coefficient data frame
xm <- data.frame(token = colnames(dfm.grouped),
                 freq = colSums(dfm.grouped))
xm$token <- as.character(xm$token)
tmp <- tmp %>% left_join(xm, by = "token")
tmp <- tmp %>% rename(coef = `1`)

#plot
library(ggplot2)
library(ggrepel)
plot1 <- tmp %>% arrange(desc(freq)) %>%
  slice(1:20) %>% 
  ggplot(aes(x = coef, y = freq))+
  geom_text_repel(aes(label = token), max.overlaps = 20)+
  labs(title = "Coefficients with Token Frequency",
       x = "Coefficient",
       y = "Token Frequency") +
  theme_classic()
print(plot1)

#better plot
makedat <- tmp %>% 
  filter(abs(coef) > 0) %>%
  arrange(desc(coef))

plotdat <- makedat %>% 
  group_by(abs(coef > 0)) %>%
  arrange(desc(abs(coef))) %>%
  slice(1:floor(10))

library(forcats)
plot_out <- plotdat %>%
  arrange(desc(coef)) %>%
  ggplot(aes(x = fct_reorder(token, -coef), 
             y = coef))+
  geom_col()+
  labs(x = "Tokens",
       y = "Coefficient",
       title = "Tokens by Party Association",
       subtitle = "total non-zero coefficients")+
  coord_flip()+
  theme(axis.text = element_text(size = 10))

print(plot_out)

# project documents
proj <- data.frame(textir::srproj(fit, EO_dfm))
proj$index <- rownames(proj)
proj$president <- EO_dfm$president

mylist <- list(coefs = tmp,
               projections = proj)

##second MIR with race considered
#group by author
dfm.grouped2 <- dfm_group(race_dfm, groups = president)

#define terms
X2 <- convert(race_dfm, to = "data.frame")
Y2 <- ifelse(race_dfm@docvars$party == "R", 1, 0)

#run model
fit2 <- dmr(counts = X2[,2:ncol(X2)], covars = Y2, cl = NULL)

#save model
save(fit2, file = "fit2.RData")
#store coefficients
c2 <- coef(fit2)
#make coefficient frame
tmp2 <- as.data.frame(as.matrix(t(c2)))
tmp2$token <- rownames(tmp2)
# put term frequencies back on coefficient data frame
xm2 <- data.frame(token = colnames(dfm.grouped2),
                  freq = colSums(dfm.grouped2))
xm2$token <- as.character(xm2$token)
tmp2 <- tmp2 %>% left_join(xm2, by = "token")
tmp2 <- tmp2 %>% rename(coef = `1`)

#save df
save(tmp2, file = "tmp2.RData")

#plot from example code
library(ggplot2)
makedat2 <- tmp2 %>% 
  filter(abs(coef) > 0) %>%
  arrange(desc(coef))

plotdat2 <- makedat2 %>% 
  group_by(abs(coef > 0)) %>%
  arrange(desc(abs(coef))) %>%
  slice(1:floor(10))


plot_out2 <- plotdat2 %>%
  arrange(desc(coef)) %>%
  ggplot(aes(x = fct_reorder(token, -coef), 
             y = coef))+
  geom_col()+
  labs(x = "Tokens",
       y = "Coefficient",
       title = "Tokens by Party Association",
       subtitle = "total non-zero coefficients")+
  coord_flip()+
  theme(axis.text = element_text(size = 10))

print(plot_out2)

#sr projections
proj2 <- data.frame(textir::srproj(fit2, race_dfm))
proj2$index <- rownames(proj2)
proj2$president <- race_dfm$president

#take the average sufficient reduction projections by president and extract for easier visualisation 
try <- proj2 %>% 
  group_by(president) %>% 
  mutate(average = mean(X1),
         dummy = 0)

tib<- tibble(president = c("Bush", "Obama", "Trump"), 
             SR = c(.7364630, -.4281140, .7815787), 
             dum = 0)

column<- ggplot(tib, aes(x = SR, y = dum, label = president)) +
  geom_point() +
  geom_line() +
  geom_text(vjust = 2, angle = 30)+
  theme(legend.position = "none") +
  theme_classic() +
  theme(axis.title.y =element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y=element_blank()) +
  labs(x = "Projections", title = "Average Sufficient Reduction Projections by President")
column <- column + theme(legend.position = "none")
print(column)