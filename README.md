# MATLAB function

## waitbar_embedded.m
** *WAITBAR_EMBEDDED displays a waitbar inside to the axes given as parameter or current axes.* **

## Definition

   **H = WAITBAR_EMBEDDED(X, AX, property, value, property, value, ...)**  
creates and displays a waitbar of fractional length X. 

> The handle to the waitbar axes is returned in H.

> X should be between 0 and 1.

> AX can be supplied as a parameter by handle or unique tag.

> Optional arguments property and value allow to set corresponding waitbar properties.

## Usage
* WAITBAR_EMBEDDED(X) will set the length of the bar in the most recently created axes to the fractional length X.

* WAITBAR_EMBEDDED(X,AX) will set the length of the bar in axes AX to the fractional length X.mod(a,m)

WAITBAR_EMBEDDED is typically used inside a FOR loop that performs a
   lengthy computation.

>Example:

    
>       h = waitbar_embedded(0,'String','Please wait...');
      for i=1:1000
           %computation here 
           waitbar_embedded(i/1000,h);
      end

## Changelog
* 2017/11/22: Design


## Author
*Mariano Aránguez Iglesias - Industrial Engineer*