Mod.require ->
 text = '''
#Using the Chrome App

 Click **folder icon** on the toolbar to open the folder containing images. The images in that folder can be added to wallapatta document by giing the relative path. For example, assume the image folder is ``home/mydocs/images`` and there is a file called ``logo.png`` in that folder. Click on the folder icon and select images folder. Then the image file can be referenced in wallapatta as ``images/logo.png``. <--<span>test</span>-->

 >>>
  <<<
   <i class="fa fa-4x fa-folder"></i>

  Folder Icon

 Click **upload icon** on the toolbar to open a wallapatta document.

 >>>
  <<<
   <i class="fa fa-4x fa-upload"></i>

  Upload Icon

 Click **download icon** on the toolbar to save an opened file.

 >>>
  <<<
   <i class="fa fa-4x fa-download"></i>

  Download Icon

 Click **save as icon** on the toolbar to save the current document to a new file. For instance you can start off using Wallapatta by saving this sample document onto your computer by clicking the save as icon.

 >>>
  <<<
   <i class="fa fa-4x fa-save"></i>

  Save As Icon

 Click **print icon** on the toolbar to print the document. It will ask for the page size. The width and height is the content area of a page (excluding margins). Wallapatta adds smart **page breaks** by analyzing your entire document. It minimizes ugly breaks such as breaks in the middle of paragraphs, etc.

 >>>
  <<<
   <i class="fa fa-4x fa-print"></i>

  Print Icon

#Wallapatta Syntax
 ##Headings

  Headings have the same syntax as Markdown. ``#`` for level 1 headings, ``##`` for
  level 2 headings and so on. The content that belongs to the heading should be
  indented.

  ```
   #Heading

    Indented content

 ##Paragraphs

  Again, similar to Markdown. Paragraphs are separated by blank lines.

  ```
   Paragraph1
   More of paragraph1

   Paragraph2

 ##Lists

  Ordered lists begin with ``-`` while unordered lists begin with ``*``.
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

 ##Images

  Images can be added with ``!``.

  >>>
   !/assets/icon128.png

  ```
   !/assets/icon128.png

  Inline images can be added by surrounding the image URL with double square brackets (``[[`` and ``]]``).

  ```
   This is a sentence which contains an [[/assets/icon128.png]] inline image.

  >>>
   This is a sentence which contains an [[/assets/icon128.png]] inline image.

 ##Side Notes

  Side notes can be added by ``>>>``. It is possible to have any other component inside side notes. The content belonging to the side note is specified via indentation.

  ```
   >>>
    This is a **side note** containing text, a list and an image.

    - One
    - Two
    - Three

    !/assets/icon128.png

  >>>
   This is a **side note** containing text, a list and an image.

   - One
   - Two
   - Three

   !/assets/icon128.png

 ##Special Blocks

  This is similar to block quotes in Markdown. Special blocks are specified
  by ``+++``. The content is identified using indentation.

  ```
   +++
    **This is a special segment.

    Can have all the other things like images.

    !/assets/icon128.png

  +++
   **This is a special segment.

   Can have all the other things like images.

   !/assets/icon128.png

 ##Code Blocks

  Code blocks are identified by three backtick quotes (`). To enable syntax highlighting, specify the language after the three backtick quotes.

  ```
   ```javascript
    function test() {
         var i = 10
    }

  ```javascript
   function test() {
         var i = 10
   }

 ##Tables

  Tables can be specified with ``|||``, and cells can be separated by ``|``. The content belonging to the table are indentified through indentation. Headers can be differentiated by following any row of cells with three equal signs (``===``).

  ```
   |||
    Header 1 | Header 2 | 3rd Header
    ===
    Cell 1 | Cell 2 | Third Cell
    Cell 4 | Cell 5 | Sixth Cell

  >>>
   It's possible to have empty cells, have more than one header-styled row, and have spanned columns.

  |||
   Header 1 | Header 2 | 3rd Header
   ===
   Cell 1 | Cell 2 | Third Cell
   Cell 4 | Cell 5 | Sixth Cell

  And here's an example of a table with spanned columns:

  ```
   |||
    Name | | Age
    First | Last |
    ===
    Foo | Bar | 25
    Baz | Fib | 19

  |||
   Name | | Age
   First | Last |
   ===
   Foo | Bar | 25
   Baz | Fib | 19

 ##HTML Blocks

  HTML blocks are identified by ``<<<``.

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

 ##Bold

  Text can be made bold with ``**``.

  ```
   **This is bold** and this is not.

   **This entire paragraph is bold.
   Still the same paragraph.

  >>>
   **This is bold** and this is not.

   **This entire paragraph is bold.
   Still the same paragraph.

 ##Italics

  Text can be italicized with ``--``.

  ```
   --This is italics-- and this is not

   --This entire paragraph is in italics.
   Still the same paragraph

  >>>
   --This is in italics-- and this is not

   --This entire paragraph is in italics.
   Still the same paragraph

 ##Superscripts and Subscripts

  Superscripts are wrapped inside ``^^ ^^`` and subscripts are wrapped inside
  ``__ __``.


  ```
   * 2^^2^^ = 4
   * CO__2__

  >>>
   * 2^^2^^ = 4
   * CO__2__

 ##Inline Code

  Inline code is identified by two backticks (`).

  ```
   Click ``apply`` to save changes.

  >>>
   Click ``apply`` to save changes.

 ##Links

  Links are wrapped inside ``<< >>``. The link text can be specified within
  brackets.

  ```
   * <<http://www.twitter.com/vpj(My Twitter Account)>>
   * <<http://blog.varunajayasiri.com>>

  >>>
   * <<http://www.twitter.com/vpj(My Twitter Account)>>
   * <<http://blog.varunajayasiri.com>>

 ##Comments

  Comments can be specified with three forward slashes (``///``). All text typed inside a comment will be ignored, along with any other components or formatting used inside.

  ```
   >>>
    This is a sentence.

    ///This is a **comment** with some text, which won't appear

    And this is yet another sentence.

  >>>
   This is a sentence.

   ///This is a **comment** with some text, which won't appear

   And this is yet another sentence.
'''

 Mod.set 'Wallapatta.Sample', text
