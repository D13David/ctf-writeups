# Hack The Boo 2023

## SpellBrewery

> I've been hard at work in my spell brewery for days, but I can't crack the secret of the potion of eternal life. Can you uncover the recipe?
>
>  Author: N/A
>
> [`rev_spellbrewery.zip`](rev_spellbrewery.zip)

Tags: _rev_

## Solution
We are given a zip archive. The archive mainly contains an executable and a dll. The dll is a `.net` dll, so we fire up `ILSpy` to see whats going on.

```c#
switch (Menu.RunMenu())
{
case Menu.Choice.ListIngredients:
    ListIngredients();
    break;
case Menu.Choice.DisplayRecipe:
    DisplayRecipe();
    break;
case Menu.Choice.AddIngredient:
    AddIngredient();
    break;
case Menu.Choice.BrewSpell:
    BrewSpell();
    break;
case Menu.Choice.ClearRecipe:
    ClearRecipe();
    break;
}
```

We have a main menu and a switch case for all the options. We can get a list of possible ingredients, we can add ingredients to our recipe, we can display the current state of our recipe, we can clear our recipe and we can brew a spell with the recipe we build.

All this being very interesting we need to find our target. After some browsing around we see the flag is given in `BrewSpell`.

```c#
private static void BrewSpell()
{
	if (recipe.Count < 1)
	{
		Console.WriteLine("You can't brew with an empty cauldron");
		return;
	}
	byte[] bytes = recipe.Select((Ingredient ing) => (byte)(Array.IndexOf(IngredientNames, ing.ToString()) + 32)).ToArray();
	if (recipe.SequenceEqual(correct.Select((string name) => new Ingredient(name))))
	{
		Console.WriteLine("The spell is complete - your flag is: " + Encoding.ASCII.GetString(bytes));
		Environment.Exit(0);
	}
	else
	{
		Console.WriteLine("The cauldron bubbles as your ingredients melt away. Try another recipe.");
	}
}
```

The recipe items are tested against a list of correct items. If this condition is given the flag is encoded by the index of one ingredient within the in the list of all ingredient names added with a constant of 32 and then converted to the corresponding `ascii` character. Skipping all the brewery we can just get the flag on our own by doing exactly what the code above is doing.

```python
correct = [
        "Phantom Firefly Wing", "Ghastly Gourd", "Hocus Pocus Powder", "Spider Sling Silk", "Goblin's Gold", "Wraith's Tear", "Werewolf Whisker", "Ghoulish Goblet", "Cursed Skull", "Dragon's Scale Shimmer",
        "Raven Feather", "Dragon's Scale Shimmer", "Zombie Zest Zest", "Ghoulish Goblet", "Werewolf Whisker", "Cursed Skull", "Dragon's Scale Shimmer", "Haunted Hay Bale", "Wraith's Tear", "Zombie Zest Zest",
        "Serpent Scale", "Wraith's Tear", "Cursed Crypt Key", "Dragon's Scale Shimmer", "Salamander's Tail", "Raven Feather", "Wolfsbane", "Frankenstein's Lab Liquid", "Zombie Zest Zest", "Cursed Skull",
        "Ghoulish Goblet", "Dragon's Scale Shimmer", "Cursed Crypt Key", "Wraith's Tear", "Black Cat's Meow", "Wraith Whisper"
]

IngredientNames = [
        "Witch's Eye", "Bat Wing", "Ghostly Essence", "Toadstool Extract", "Vampire Blood", "Mandrake Root", "Zombie Brain", "Ghoul's Breath", "Spider Venom", "Black Cat's Whisker",
        "Werewolf Fur", "Banshee's Wail", "Spectral Ash", "Pumpkin Spice", "Goblin's Earwax", "Haunted Mist", "Wraith's Tear", "Serpent Scale", "Moonlit Fern", "Cursed Skull",
        "Raven Feather", "Wolfsbane", "Frankenstein's Bolt", "Wicked Ivy", "Screaming Banshee Berry", "Mummy's Wrappings", "Dragon's Breath", "Bubbling Cauldron Brew", "Gorehound's Howl", "Wraithroot",
        "Haunted Grave Moss", "Ectoplasmic Slime", "Voodoo Doll's Stitch", "Bramble Thorn", "Hocus Pocus Powder", "Cursed Clove", "Wicked Witch's Hair", "Halloween Moon Dust", "Bog Goblin Slime", "Ghost Pepper",
        "Phantom Firefly Wing", "Gargoyle Stone", "Zombie Toenail", "Poltergeist Polyp", "Spectral Goo", "Salamander Scale", "Cursed Candelabra Wax", "Witch Hazel", "Banshee's Bane", "Grim Reaper's Scythe",
        "Black Widow Venom", "Moonlit Nightshade", "Ghastly Gourd", "Siren's Song Seashell", "Goblin Gold Dust", "Spider Web Silk", "Haunted Spirit Vine", "Frog's Tongue", "Mystic Mandrake", "Widow's Peak Essence",
        "Wicked Warlock's Beard", "Crypt Keeper's Cryptonite", "Bewitched Broomstick Bristle", "Dragon's Scale Shimmer", "Vampire Bat Blood", "Graveyard Grass", "Halloween Harvest Pumpkin", "Cursed Cobweb Cotton", "Phantom Howler Fur", "Wraithbone",
        "Goblin's Green Slime", "Witch's Brew Brew", "Voodoo Doll Pin", "Bramble Berry", "Spooky Spellbook Page", "Halloween Cauldron Steam", "Spectral Spectacles", "Salamander's Tail", "Cursed Crypt Key", "Pumpkin Patch Spice",
        "Haunted Hay Bale", "Banshee's Bellflower", "Ghoulish Goblet", "Frankenstein's Lab Liquid", "Zombie Zest Zest", "Werewolf Whisker", "Gargoyle Gaze", "Black Cat's Meow", "Wolfsbane Extract", "Goblin's Gold",
        "Phantom Firefly Fizz", "Spider Sling Silk", "Widow's Weave", "Wraith Whisper", "Siren's Serenade", "Moonlit Mirage", "Spectral Spark", "Dragon's Roar", "Banshee's Banshee", "Witch's Whisper",
        "Ghoul's Groan", "Toadstool Tango", "Vampire's Kiss", "Bubbling Broth", "Mystic Elixir", "Cursed Charm"
]

for ingredient in correct:
    print(chr(IngredientNames.index(ingredient)+32),end="")
```

Flag `HTB{y0ur3_4_tru3_p0t10n_m45st3r_n0w}`