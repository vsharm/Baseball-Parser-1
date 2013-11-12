This project uses the libXML parser to crawl data from Fangraphs.com, BaseballProspectus.com, and Baseball-Reference.com

It uses multithreading API's to download the webpages simultaneously.

![alt tag](http://cl.ly/RuWc/Screen%20Shot%202013-10-11%20at%203.33.04%20PM.png)

Known Problems:

The code is not rather elegant and almost speggetti like. The poor nature of the code lead to the development of baseball parser 2.

If two players share the same names the program will not work.

The program does not have the intellegence to choose if a player is a pitcher or a hitter if that player is a 2 way player(Hitter and Pitcher such as Babe Ruth).

These problems are fixed in BaseballParser2
