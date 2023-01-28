#!/bin/bash 
if [ -z "$var" ]
then
  printf "Please provide SharePoint website name\n"
else
  $sitename = $1
fi

function convert_file() {
	# Convert file to html 
	pandoc -f dokuwiki -t html "$1" -o "$1"
}

function remove_newlines() { 
	# Remove newlines
	outfile="${1/.txt/.html}"
	tr -d '\n' < $1 >$outfile
}

function replace_hyphens() { 
	# Replace hyphens added by tr
	sed -i 's/-//g' $outfile
}

function replace_urls() {
	page_urls $1
	image_urls $1
	file_urls $1
}

function page_urls() {
	sed -i "s/a href=\"\/\(.*\)\"/a href=\"\/sites\/$sitename\/Pages\/\1.aspx\"/g" $1
}

function image_urls() {
	sed -i 's/img src=\"\/\(.*\)\"/img src=\"\/sites\/$sitename\/Documents\/media\/\1\"/g' $1
}

function file_urls() { 
	# Read more than one line input stream - as embed src usually over two lines...
	sed -i '/./{H;$!d} ; x ; s/embed\nsrc=\"\/\(.*\)\/\([a-zA-Z0-9\s]*[.][a-zA-Z]*\)\".*>/a href=\"\/sites\/$sitename\/Documents\/\1\/\2\">\2<\/a>/g' $1
}

function escape_syntax() {
	sed -i 's/[^\]\(\\[0-9]\)/\\\1/g' $1
}

function html_escape() {
	# HTML escape
	sed -i 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' $outfile
}


function replace_in_template() { 
	sed -i 's/&/\\&/g; s/|/\\|/g' $outfile
	txt=$(cat $outfile)
	finalfile="${outfile/.html/.aspx}"
	sed "s|REPLACEME|$txt|g" test/about.aspx > $finalfile
}

function caller_function() { 
	printf "Converting file %s " $1
	printf "."
	convert_file $1
	printf "."
	replace_urls $1
	printf "."
	escape_syntax $1
	printf "."
	remove_newlines $1
	printf "."
	replace_hyphens $outfile
	printf "."
	html_escape $outfile
	printf "."
	replace_in_template $outfile
	printf "."
	rm $1
	printf "."
	rm $outfile
	printf " Finished \n"
}

export -f convert_file
export -f remove_newlines
export -f replace_hyphens
export -f replace_urls
export -f html_escape
export -f replace_in_template
export -f file_urls
export -f image_urls
export -f page_urls
export -f caller_function
export -f escape_syntax

find wiki/data/pages -type f -exec bash -c "caller_function \"{}\"" \;
