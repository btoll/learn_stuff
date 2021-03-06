#!/bin/bash
# Download a Vim tip of the day from the internet!

FILE="votd.html"

getTip ()
{
    rm "$FILE" 2> /dev/null
    # Let's download and save it so we can operate on it before mailing it.
    # As of 20140608, there were 1,611 tips on http://vim.wikia.com/wiki/Vim_Tips_Wiki
    # There isn't a web service, so let's cap the range there.
    TIP=$((( RANDOM % 1611 ) + 1 ))
    # The tips take the format of http://vim.wikia.com/wiki/VimTip538
    URL=http://vim.wikia.com/wiki/VimTip$TIP
    curl -o $FILE $URL

    # Resend if it's not a helpful tip!
    #
    # Text from removed tips:
    #       Tip 657 does not exist
    #       Tip 1241 has been removed
    if ag "Tip $TIP does not exist" $FILE; then
        getTip
    elif ag "Tip $TIP has been removed" $FILE; then
        getTip
    fi
}

getTip

# Delete everything but the user-inputted tip. Yes, it's VERY specific to the HTML template.
sed -i -e '/<b>created<\/b>/,/NewPP limit report/!d' $FILE 2>/dev/null

# Wrap the HTML fragment and include a link to the tip.
echo '<html><body><p><a href='$URL'>View Tip '$TIP' on vim.wikia.com</a></p><br />' > tmp

# We want to delete the last 2 lines of the file (i.e., "<!-- \n NEWPP limit report"). This is a PITA
# to do with just sed, so let's get some help from our friend tac.
tac $FILE | sed '1,2d' | tac >> tmp

echo '</body></html>' >> tmp
mv tmp $FILE

# Now that we have a safer download, let's email it!
php votd.php $FILE

rm $FILE

