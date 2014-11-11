Mod.require ->
 text = '''
#Docscript Sample

 Following is a sample document to illustrate how to use docscript.

 We are using docscript to generate software user manuals at Forestpin.

 Docscript is inspired by markdown. We developed this because markdown didn't
 fit out requirement. Docscript is available on github.

 ##Visualizing numerical tables

  Here's a number of alternatives to displaying table of numbers. We
  have evaluated them in terms of,

   - **Reading numbers
   - **Finding the largest and smallest
   - **Getting an idea about the distribution

  If there is only one column of numbers, the table can be sorted by that. But
  there is a bit of a problem when there are multiple columns and you want to
  see the relationship between two columns. In which case you will have to sort
  by one of the columns and understand the distribution of the other column
  relative to that.

  ###Listing numbers

   The simplest and often the best way is to simply list them. Right aligned
   numbers help quick scanning and comparison.

   !assets/list.png

   ---
   --The table is sorted by the first column.

   If there are very large or small numbers the reader should be able to
   spot them quickly because the number of digits in those numbers would differ
   from the rest.
   ---

   If the reader wants to get an idea about the distribution or range of numbers
   in a non-sorted column she will have to go through the each of the numbers.


  ###Bars
   Adding a bar, like in a horizontal bar chart, helps you clearly identify
   the largest value and understand the distribution without having to
   read through the numbers.

   !assets/bars.png

   ---
   --The length of the green bars is proportional to the value in the list.

   Less prominent color choice for the bars would minimize the distraction.
   ---

   The bars take up a lot of space - at least another column. Displaying text
   over bars reduces the space, but it makes it lot harder to read the numbers.

   !assets/bars-text.png

   ---
   It would be even more distracting if the numbers were right aligned.
   ---

  ###Underline

   A thin line underneath the numbers instead of the bars can give
   a visual indication of the values, without taking much space.

   !assets/underline.png

   ---
   --The scale of the line lengths is linear.

   Larger and smaller numbers of the second column can be identified without
   reading numbers. It takes a lot less time to understand the distribution and
   any outliers can be spotted easily.
   ---

   Right aligning the bars eliminated minimizes clutter. A subtle line color
   and/or thinner lines will help reduce distraction even more.

   The distribution of numbers can be identified even when viewing from a
   distance or with a **blurry** vision.

   ---
   !assets/blur.png

   --A blurred copy of the table
   ---


   The scale of the lines could be linear or logarithmic depending on the
   distribution of the numbers. For better understanding, a small axis could be
   placed at the column headings.
 '''

 Mod.set 'Docscript.Sample', text
