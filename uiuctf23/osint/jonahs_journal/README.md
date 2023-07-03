# UIUCTF 2023

## Jonah's Journal

> After dinner, Jonah took notes into an online notebook and pushed his changes there. His usernames have been relatively consistent but what country is he going to next? Flag should be in format uiuctf{country_name}
>
>  Author: N/A
>

Tags: _osint_

## Solution
We are looking for a journal now and have the hint that the usernames are relatively consistent. Thats good, because we know the twitter user already. There is another hint hidden in the text, since Jonah `pushes` his changes to his online notebook, what if the online notebook is actually a github repository? And [`indeed`](https://github.com/JonahExplorer), there is a matching user.

There is one repository `adventurecodes` and the README.md contains the following:

```
# adventurecodes
storing all my adventure codes

I think that the next place I wanna visit is the great wall of china, but not until I get off of flight UA5040  
```

Flight UA 5040 went from Chicago to Johnstown, but the next place Jonah wants to visit is the great wall of China. Since `china` is not working as a flag, we check further. There is a second branch `entry-2` with two newer submits:

```
    storing all my adventure codes

    I think that the next place I wanna visit is the great wall of china, but not until I get off of flight UA5040 
+
+   I dont know how these things work but my next destination is not China but actually italy. After I check out from my hotel in the west loop, I'll be heading there. 
```

```
    I think that the next place I wanna visit is the great wall of china, but not until I get off of flight UA5040 

+   Sometimes i forget how these "branches" work, kinda like a tree right? 
```

So the next destination was not China but Italy.

Flag `uiuctf{italy}`