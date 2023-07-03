# UIUCTF 2023

## Finding Artifacts 1

> David is on a trip to collect and document some of the world’s greatest artifacts. He is looking for a coveted bronze statue of the “Excellent One” in New York City. What museum is this located at? The flag format is the location name in lowercase, separated by underscores. For example: uiuctf{statue_of_liberty}
>
>  Author: N/A
>

Tags: _osint_

## Solution
From the solution we are looking for a bronze statue somewhere in a New York museum. I tried to google for `bronze statue "Excellent One"` and got some good results. Amongst them [`The Mahakala `](https://collection.rubinmuseum.org/objects/167/mahakala;jsessionid=4F7643D06D0B687EBA00AC587B974927). In the description it says
> This bronze of the protector deity Mahakala presents him as “the Excellent One,” a particularly fierce form with a large head, gaping mouth, heavy coat and boots, and holding a large sandalwood club in both hands in front of his body.

This fits good. On the same page the `Credit Line` goes to `Rubin Museum of Art`. After trying some combinations for the flag, the working version was `uiuctf{the_rubin_museum}`.

Flag `uiuctf{the_rubin_museum}`