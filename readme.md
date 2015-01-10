#Wallapatta

Wallapatta has a syntax similar to
[Markdown](http://en.wikipedia.org/wiki/Markdown) and uses a layout
inspired by handouts of Edward R. Tufte.

##Overview

Wallapatta uses indentation to specify the hierarchy of content, and identify the context each component belongs to.

```
###Heading1

 Introduction

 * Point one

  Description about point one

 ####Subtopic

  Subtopic content

 This belongs to Heading1
```

Indentation is required for specifying content for components like lists, code blocks, special blocks, etc.
 
It also helps while working with large documents because **code folding** can be used with Wallapatta. The hierarchy of content is important for printing as well- to indentify where to break pages.

Side notes are another key feature of Wallapatta. You can have text, lists, links, HTML content, as well as images, in side notes.

We've changed some of the syntax from Markdown; for instance, ``<<`` and ``>>`` are used for links instead of ``[]()``, because we felt that it's a little more intuitive due to its resemblence with HTML tags.

##[Online Editor](http://vpj.github.io/wallapatta)

Use the online editor to try out the Wallapatta syntax.

##[Documentation](http://vpj.github.io/wallapatta/introduction.html)

Check out a detailed Wallapatta documentation, written in Wallapatta itself, at [http://vpj.github.io/wallapatta/introduction.html](http://vpj.github.io/wallapatta/introduction.html)
