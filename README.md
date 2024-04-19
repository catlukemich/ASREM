# SREM

## A minigame where player becomes a Single Real Estate Manager

Run a company that manages a single real estate building - 
offices building in an unknown city. Upgrade the building
by adding floors, build a helipad on top of a building to earn
additional money from the rents. Set the rents carefully to keep 
the inhabitants content, or else, if the get angry will start 
devastating the building floors making them inhabitable. 

![](https://i.imgur.com/7FM2n0Z.png)
![](https://i.imgur.com/0HFTZC3.png)
![](https://i.imgur.com/dztQPdd.png)

## Running the game

Provided you have Python 3 with the pygame library installed, run the command

`python main.py`

## Guide

The main goal of the game is simple - gather as much funds as fast as you can.
Every month you earn money from rents. A rent slider is provided so you can set 
how much you will drain the inhabitants of the estate. 

The rent is per floor - so setting it for example at 1000 and having 4 floors will earn you 4000 credits a month, except...
Except if the floor is abandoned - then you will earn no money for that floor. Floors will
get abandoned if your inhabitants are unhappy, and they will become unhappy if you set the rent high.
To get the floor back to it's usable state, you have to make the inhabitants happy again and wait some time for themm to comeback.
The other circumstance is that you will earn only a half of the rent, when the floor is dirty.

Another feature is the ability to build helipad. If you build helipad, the total rent each month will
be 1.5X higher.

In the end you can take look at the graphs for the funds, income and contentment over time by clicking the small graph icon in the funds gauge.

That's it, good luck!

