# Ideological-Scaling-with-Presidential-Executive-Orders

## Overview
Our research focuses on presidential executive orders and how the wording used is different between Democrats and Republicans. We are specifically interested in executive orders pertaining to racial issues to better understand whether there is a clear distinction in rhetoric around race between parties. To tackle this, we take a text as data approach, which allows us to quantify words and scale them according to their party indication. I use one of several possible approaches to accomplish this task with the coding language R.

## The approach
The approach I have employed for this research is called multiple inverse regression. The main goal of MIR is to predict an explanatory variable (x) given the outcome variable (y). In the context of this research, that means predicting partisanship based on text from executive orders. These predictions come from sufficient reduction projections which are low dimensional but preserve information about the tokens. These reductions can be used to understand concepts such as the degree of partisanship, as Green et al. 2024 does using text from various venues to understand the impact of venue on political speech. 

Similar to other text analysis methods, it is imperative to first preprocess the text from our dataset. Next, the executive orders were subset by date and topic so that I was left with only executive orders from 2001 to 2021 which were potentially or likely to be about or related to race. This was done for three reasons. First, the evolving nature of language can complicate or misdirect the scaling for partisanship. Second, and practically, the formatting for this period was consistent enough to be functional with the preprocess coding. Third, as this research aims to understand differences in rhetoric around race based on political party, subsetting by topic gives me a consolidated dataset of executive orders which are more informative to our research. The final preparation of the data to fit the model was to denote party affiliation for each executive order, and tokenize the text. MIR uses unigrams, bigrams, and trigrams in order to maintain context of tokens and phrases.

Once pre-processed, the MIR model was fit in R using distrom and textir packages.                                       
## The Executive Order Data
There are 175 total executive orders from 2001 to 2021. This ranges from the start of George W. Bush’s first term to the end of Donald Trump’s first term. Bush wrote 53, Obama wrote 49, and Trump wrote 73. This means Trump makes up 41.71% of the executive orders despite the data covering only one of his presidential terms. The average number of tokens per document is 1334. The minimum is 73 tokens and the maximum is 9799 tokens. Table 1 shows further summary statistics grouped by president.

<img width="1210" height="774" alt="summary" src="https://github.com/user-attachments/assets/42ccfb91-9c4f-474d-a990-a10b122db076" />

## Results 
Results from the MIR model return coefficients for each token which represent the conditional relationship between the speech and partisanship. Figure 1 shows the most impactful tokens for each predictor (democrat and republican). Following standard demarcation of partisanship in the political science field, Republican is represented as 1 and Democrat as 0.

<img width="1214" height="778" alt="figure1" src="https://github.com/user-attachments/assets/a0890b12-ba53-40a9-91a8-67bf1e3b9874" />


Interestingly, these results display certain thematic differences among race related executive orders by party. For Democrats, executive orders related to race show 2 themes: assistance, and climate change. This is consistent with democratic thought and policy related to race which suggests that systematic racism has exacerbated various struggles in communities of color and will continue to do so if intervention does not happen, as outlined by previous Diversity, Equity, and Inclusion policy (The White House). Recently, climate change has been especially poignant in current events, and has been more widely accepted by Democrats (Kennedy and Tyson, 2024) which supports the validity in its appearance as a prevalent token in these executive orders. 

Tokens most associated with Republicans have a notably different sentiment. The driving rhetoric of Republican speech related to race could be described as fear, with tokens like “threaten” and “terrorist” listed as indicative terms. Given that the Republican party has made a concerted effort to separate themselves from Democratic DEI policy, it is expected that their tokens reflect this separation.

To evaluate the face validity of the MIR approach for this research, I scaled the presidents’ predicted partisanship using their average sufficient reduction projections in Figure 2. Obama is significantly to the left of Bush and Trump, with Trump at the rightmost point on the scale. Granted, left-right political ideology is not considered a concrete science to pin down (Green et al., 2024), this scale is consistent with the general understanding of the political leanings of each president. This evaluation shows the validity of this approach and my further findings. 

<img width="1214" height="778" alt="proj scale" src="https://github.com/user-attachments/assets/6a5dcfac-c2ac-44ae-a768-24e48c71d491" />


## Implications
The validity tests for the MIR approach prove that it is a promising approach to understand partisan divides in speech regarding race. The sufficient reduction projections reflect a scale similar to what we would expect from Bush, Obama, and Trump’s political tendencies. Additionally, general topics and sentiment in tokens with the most predictive coefficients are aligned with party policy. Therefore, we can confidently pull from MIR results of executive orders to understand party rhetoric surrounding race. Namely, Democratic thought and policy around race in Executive Orders is largely driven by climate change as a specific issue. On the other hand, Republican speech about race is driven by sentiment. Further analysis should be done to include more presidents in the dataset. 

## Works Cited
The White House. “Advancing Equity and Racial Justice Through the Federal Government.” https://bidenwhitehouse.archives.gov/equity/

Green et al. “Cross-Platform Partisan Positioning in Congressional Speech.” Political Research Quarterly 77, no. 3 (2024): 653-668.

Kennedy, Brian and Tyson, Alec. “How Americans View Climate Change and Policies to Address the Issue.” Pew Research Center, December 9, 2024, https://www.pewresearch.org/science/2024/12/09/how-americans-view-climate-change-and-policies-to-address-the-issue/ 

