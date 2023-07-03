# UIUCTF 2023

## What's for Dinner?

> Jonah Explorer, world renowned, recently landed in the city of Chicago, so you fly there to try and catch him. He was spotted at a joyful Italian restaurant in West Loop. You miss him narrowly but find out that he uses a well known social network and and loves documenting his travels and reviewing his food. Find his online profile.
>
>  Author: N/A
>

Tags: _osint_

## Solution
After searching around in Chicago West loop a bit (and checking the hint `what does joy translate to?`), one of the restaurants fits the description, the [`Gioia Chicago`](https://goo.gl/maps/P8ty7LoUd2njDQwu6). After searching the reviews and images for some time (1) without luck I tried to guess which `well known social network` could be meant and luckily found a result [`here`](https://twitter.com/JonahExplorer). And indeed there is one tweet with the flag.

(1) I searched the google maps reviews. When googling for "Gioia Chicago reviews" a [`Yelp`](https://www.yelp.com/user_details?userid=mTYyKuWsmsvYKizuwwvAmA) profile can be found with one post where the twitter handle is given:
> I came here during a trip to chicago and it was absolutely amazing. I loved the food here and the chocolate cake was really good. I loved posting the food I had onto Twitter (@jonahexplorer) where I talk about different restaurants I go to. I would give the food 10/10. Definitely worth coming to again!

The server was really nice as well and service was unmatched. he constantly made sure that we felt comfortable as well as getting us water and other little small things. Finally, the setting of the food and the ambiance made the whole night.

Flag `uiuctf{i_like_spaghetti}`