# RACharts

Telegram's contest chart implementation using OpenGL.

<p align="center">
<img src="https://github.com/Moonko/RACharts/blob/master/Screenshot4.png" width="250"><img src="https://github.com/Moonko/RACharts/blob/master/Screenshot2.png" width="250"><img src="https://github.com/Moonko/RACharts/blob/master/Screenshot3.png" width="250"">
</p>

## 1st stage - 4th place

Telegram rated the app as nice as fast but charts were placed in different screens.

## 2nd stage - 3rd place & ratings 1st place

The app got 4/5 admins' votes and the 1st place in the constest's rating but I didn't implement the bonus goals.

<p align="center">
<img src="https://github.com/Moonko/RACharts/blob/master/Screenshot1.PNG" width="300">
</p>

## Implementations remarks

* Theme change supports any property like color, font, text or even views to be changed;
* The app could support any number of themes not just black or white.
* Y scale can separately calculate up to N charts;
* Y scale calculator is replaceable. For now it has 3 implementations: sum, common and separate Y calculations.
* Y renderer is replaceable. For now it renders horizontal lines for 1 or 2 charts;
* X renderer is replaceable. For now it renders dates under the chart;
* Chart renderer is replaceable. For now it has 3 implementations: line, bar and area;

## What could be done better

* Y and X renderers implementation using OpenGL;
* Simplier interval selection view;
* Replaceable selection style;
* Line joints;
* 3rd chart has issues with Pears rendering (only on real devices);
