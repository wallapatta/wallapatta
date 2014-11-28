Mod.require ->
 text = '''
#Markdown like syntax for Edward Tufte style documents

 >>>
  ###**<<http://vpj.github.io/wallapatta/(Try online editor)>>

 We started working on a documentation engine to create documents such
 as --printed user manuals--, --getting started guides--, --online help--,
 --training handouts-- and --internal documents-- at
 **<<http://www.forestpin.com(Foresptin)>>**.

 >>>
  !https://d13yacurqjgara.cloudfront.net/users/161539/screenshots/1789209/logo.png

  --Forestpin Logo

 Initially we were working with editors such as Microsoft Word. It was alright
 when we had a couple of documents but it wasn't easy to maintain formats and
 manage them as larger documents came in. Then we started looking at
 alternatives like <<http://en.wikipedia.org/wiki/LaTeX(LaTeX)>>
 and <<http://en.wikipedia.org/wiki/Markdown(Markdown)>>.

 Both these options would make managing the documentations much easier. The
 documents could be version controlled with **git**, which lets us do a number
 things: version control, branching, collaboration, etc. Although LeTeX gives
 a lot of flexibility,  it was a little too complicated,
 especially for non-technical writers.

 Markdown on the other hand was much simpler but didn't support some of the key
 features we wanted. Markdown doesn't work well when printing. It breaks pages
 random places. The other problem was that Markdown didn't support
 sidenotes.

 <<http://rmarkdown.rstudio.com/(R Markdown)>> suported formatting inspired by
 Tufte. This was the best already available option for us. We honestly didn't
 have very good reasons not to use it and develop our own.

 >>>
  <<http://rmarkdown.rstudio.com/tufte_handout_format.html(RStudio Markdown)>>
  does seem to have tufte style for Markdown.

  --<<http://sachsmc.github.io/tufterhandout/(Sample)>> -
  <<https://raw.githubusercontent.com/sachsmc/tufterhandout/master/vignettes/example.Rmd(Source)>>


 However there were a few advantages of developing our own tool:

  * Give us total control

   We would be able to modify the tool to perfectly fit our needs

  * Mardown doesn't have a structure

   For instance, in the following document,

   ```
    #Heading1
    Intro
    #Heading2
    Paragraph
    #Heading3
    Paragraph
    Conclusion

   it is not clear whether ``Conclusion`` belongs to ``Heading1`` or
   ``Heading3``. This again gives some trouble when paginating.

  * R Markdown seemed to be use verbose syntaxes for some of the commonly
   needed functions

 ###DocScript Project

  Wallapatta is available on <<https://github.com/vpj/wallapatta(Github)>>. It
  is not fully baked yet but you can give it a try.

  >>>
   #####**<<https://github.com/vpj/wallapatta(Fork me on github)>>


  Here are some of the sample documents we've created:

   * <<http://vpj.github.io/wallapatta/benford.html(Benford's Law Test)>>
   * <<http://vpj.github.io/wallapatta/dashboard.html(Forestpin Dashboard)>>
   * <<http://vpj.github.io/wallapatta/correlation.html(Correlation Test)>>

 ###Usage

  The online compiler is available at <<http://vpj.github.io/wallapatta/>>.

  The command line interface requires ``nodejs`` and ``coffeescript``. You need
  to get the git submodules with ``git submodule init`` and
  ``git submodule update`` after cloning wallapatta.

  >>>
   A few npm packeges such as ``optimist`` are required.


  ```
   ./wallapatta.coffee -i input_file -o output_file

  This will create the output html file inside ``build`` directory. The CLI is
  still in early stages.

 ##Design

  Wallapatta uses indentation to specify hierarchy of content.

  +++
   ####Example

    ```
     ###Heading1

      Introduction

      * Point one

       Description about point one

      ####Subtopic

       Subtopic content

       More subtopic content

      This belongs to Heading1

    >>>
     ###Heading1

      Introduction

      * Point one

       Description about point one

      ####Subtopic

       Subtopic content

       More subtopic content

      This belongs to Heading1

  Althought indentation doesn't help much in standard rendering except in a
  a few cases (e.g. lists) it's has a number of of other uses. It lets us
  programmetically set page breaks when printing (not implemented yet).
  Other advantage is we can use **code folding** when editing; which come handy
  when working with large documents.

  Another key feature of wallapatta is sidenotes. You can have notes as well
  as images in sidenotes.

  >>>
   <<<
    <a href="https://twitter.com/share" class="twitter-share-button" data-via="vpj" data-size="large">Tweet</a>
    <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>

   --Tweet this button in a sidenote^^1^^

  We've changed some syntaxes of Markdown; for instance, ``<<`` and ``>>`` are
  used for links instead of ``[]()``, because we felt it was a little more
  intuitive (resemblence with HTML tags).

  Wallapatta introduces HTML blocks marked by ``<<<``, where you can add
  any HTML content.

  >>>
   ^^1^^That's how we added the tweet button.

 ##Reference

  ###Headings

   Headings have the same syntax as Markdown. ``#`` for level 1 headings ``##`` for
   level 2 headings and so on. The content that belongs to the heading should
   indented.

   ```
    #Heading

     Indented content

  ###Paragraphs

   Again similar to Markdown. Paragraphs are separated by blank lines.

   ```
    Paragraph1
    More of paragraph1

    Paragraph2

  ###List

   Ordered lists begin with ``- `` while unordered lists begin with ``* ``.
   Since lists can be structured with indentations, it's easy to have lists
   within lists.

   ```
    - Introduction
    - Analyses

     - Daily analysis
     - Benford's law
     - Timeseries analysis
    - Visualizations

     * Treemap
     * Bar charts
     * Dashboard

   >>>
    - Introduction
    - Analyses

     - Daily analysis
     - Benford's law
     - Timeseries analysis
    - Visualizations

     * Treemap
     * Bar charts
     * Dashboard

  ###Media

   Images can be added with ``!``.

   ```
    !https://d13yacurqjgara.cloudfront.net/users/161539/screenshots/1789209/logo.png

   >>>
    !https://d13yacurqjgara.cloudfront.net/users/161539/screenshots/1789209/logo.png

  ###Special Blocks

   This is similar to block quotes in Markdown. Special blocks are specified
   by ``+++``. The content is identified using indentation.

   ```
    +++
     **This is a special segment.

     Can have all the other things like images.

     !https://d13yacurqjgara.cloudfront.net/users/161539/screenshots/1814286/d1.png

   +++
    **This is a special segment.

    Can have all the other things like images.

    !https://d13yacurqjgara.cloudfront.net/users/161539/screenshots/1814286/d1.png

  ###Code Blocks

   Code blocks are identified by three backtick quotes (`).

  ###Html Blocks

   Html blocks are identified by ``<<<``.

   ```
    <<<
     <blockquote class="twitter-tweet" lang="en"><p>Wallapatta <a href="http://t.co/iaPELYc7RL">http://t.co/iaPELYc7RL</a> Alternative to <a href="https://twitter.com/hashtag/markdown?src=hash">#markdown</a> written in <a href="https://twitter.com/hashtag/coffeescript?src=hash">#coffeescript</a></p>&mdash; Varuna Jayasiri (@vpj) <a href="https://twitter.com/vpj/status/532035802578944003">November 11, 2014</a></blockquote>
     <script async src="http://platform.twitter.com/widgets.js" charset="utf-8"></script>

   Here's a tweet embedded with an HTML block.

   <<<
    <blockquote class="twitter-tweet" lang="en"><p>Wallapatta <a href="http://t.co/iaPELYc7RL">http://t.co/iaPELYc7RL</a> Alternative to <a href="https://twitter.com/hashtag/markdown?src=hash">#markdown</a> written in <a href="https://twitter.com/hashtag/coffeescript?src=hash">#coffeescript</a></p>&mdash; Varuna Jayasiri (@vpj) <a href="https://twitter.com/vpj/status/532035802578944003">November 11, 2014</a></blockquote>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

   >>>
    This won't work in online editor since the twitter script will not load

  ###Bold

   Text can be made bold with ``**``.

   ```
    **This is bold** and this is not.

    **This entire paragraph is bold.
    Still the same paragraph.

   >>>
    **This is bold** and this is not.

    **This entire paragraph is bold.
    Still the same paragraph.

  ###Italics

   Text can be made italics with ``--``.

   ```
    --This is italics-- and this is not

    --This entire paragraph is in italics.
    Still the same paragraph

   >>>
    --This is italics-- and this is not

    --This entire paragraph is in italics.
    Still the same paragraph

  ###Superscript and Subscript

   Superscript are wrapped inside ``^^ ^^`` and Subscripts are wrapped inside
   ``__ __``.


   ```
    * 2^^2^^ = 4
    * CO__2__

   >>>
    * 2^^2^^ = 4
    * CO__2__

  ###Inline code

   Inline code is identified by two backticks (`).

   ```
    Click ``apply`` to save changes.

   >>>
    Click ``apply`` to save changes.

  ###Links

   Links are wrapped inside ``<< >>``. The link text can be specified within
   brackets.

   ```
    * <<http://www.twitter.com/vpj(My Twitter Account)>>
    * <<http://www.forestpin.com>>

   >>>
    * <<http://www.twitter.com/vpj(My Twitter Account)>>
    * <<http://www.forestpin.com>>


 ###**Future Plans

  We need to add **inline images** to include small illustrations within text.
  I plan on supporting comments as well. So that we can include notes that won't
  got to the rendered document.

  A lot of work needs to be done on the CLI to render multiple files and
  to compose large document based on a number of files. I am thinking of using
  this for my blog.

 '''

 Mod.set 'Wallapatta.Sample', text
