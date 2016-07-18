# Asynk-Means
A visual representation of the k-means algorithm applied to images downloaded asynchronously.

## The algorithm
Every pixel RGB value is extracted and transformed to a CIELAB space. All pixels in an image are averaged into a single color vector which is used to run the [K-means algorithm](https://es.wikipedia.org/wiki/K-means) and cluster images in this space. Notice in the demo how it clusters images in tiles ordered vertically. Also notice that K-means is not always perfect, it might get stuck in a local minima resulting in an aparent _disorder_. 

![Alt text](demo1.gif?raw=true "iPhone demo")

### Problems
With this approach this algorithm will only work properly with images that have a single comon color. A better approach will be implemented in the future. 

## TODO
Get top 5 colors and run the algorithm in a more sensible representation of the image with a model of these five colors.

## JSON input & Image-net
A list of image links is provided in json format for download. It can be easily modified to append or change them. In the future user inputs will be configured to add new images in-app. **Warning:** this app is intended for dev purposes only and the `GRID_SIZE` variable is tightly coupled to the number of images in that list and the validity of their links, so make sure that provided links are valid and `GRID_SIZE >= urlList.count`.

Also a small python script is provided for easier integration with [image net](http://www.image-net.org/). Just search and download a synset, save it with the name `urls.txt` in the same directory of `setup.py` and run it. Then copy the resulting json into the xCode project.

Based on ideas from:
* [Swift Algorithm Club](https://github.com/raywenderlich/swift-algorithm-club)
* [DominantColor](https://github.com/indragiek/DominantColor/blob/2b1a01f0910177a402f33d0ccb5aea3af369b632/README.md) by indragiek

## Contact
* Bernardo Santana
* [@bsantanas](https://twitter.com/bsantanas)
* [bsantanas.wordpress.com](https://bsantanas.wordpress.com/)
